from f5.bigip import ManagementRoot
from icontrol.exceptions import iControlUnexpectedHTTPError
import json
import pprint
import sys
from optparse import OptionParser
import pexpect
import time
import logging
from distutils.version import LooseVersion
import requests
try:
   requests.packages.urllib3.disable_warnings()
except:
   pass

#logger = logging.getLogger('bigip_dns_helper')
#logger = logging.getLogger()
#logger.setLevel(logging.DEBUG)

class DnsHelper(object):
   def __init__(self, host, username, password, 
                peer_username=None, peer_password = None,
                partition='Common',port=443,
                shell_username=None, shell_password=None,
                peer_shell_username=None, peer_shell_password=None,
                peer_host=None):

      self.mgmt2 = None
      self.mgmt = ManagementRoot(host, username, password, port=port)

      self.host = host
      # iControl REST
      self.username = username
      self.password = password
      # SSH
      self.shell_username = shell_username
      self.shell_password = shell_password

      if not shell_username:
         self.shell_username = username

      if not shell_password:
         self.shell_password = password

      # iControl REST
      self.peer_username = peer_username
      self.peer_password = peer_password

      self.peer_shell_username = peer_shell_username
      self.peer_shell_password = peer_shell_password
      
      if not self.peer_shell_username:
         self.peer_shell_username = peer_username

      if not self.peer_shell_password:
         self.peer_shell_password = peer_password

      self.peer_host = peer_host
      self.port = port
      if peer_host:
         self.mgmt2 = ManagementRoot(peer_host, peer_username, peer_password,port=self.port)

      self.session = self.mgmt._meta_data['bigip']._meta_data['icr_session']
      self.partition = partition

      
      if LooseVersion(self.mgmt._meta_data['tmos_version']) < LooseVersion('12.1.0'):
         raise Exception,"This has only been tested on 12.1."
      self.v13 = LooseVersion(self.mgmt._meta_data['tmos_version']) > LooseVersion('12.1')

   def enable_sync(self):
      "enable sync of BIG-IP DNS config"
      payload = {"synchronization":"yes"}
      r = self.session.patch("https://%s:%s/mgmt/tm/gtm/global-settings/general" %(self.host,self.port),data=json.dumps(payload))

   def create_dns_cache(self):
      "create dns cache"
      payload = {'name':'dns_cache'}
      r = self.session.post("https://%s/mgmt/tm/ltm/dns/cache/resolver" %(self.host),data=json.dumps(payload))                 

   def add_datacenter(self,datacenter):
      "add datacenter in BIG-IP DNS"
      self.mgmt.tm.gtm.datacenters.datacenter.create(name=datacenter,partition=self.partition)

   def add_server(self,server_name,server_ip, datacenter,translation=None):
      "add server in BIG-IP DNS"
      addresses = [{'name': server_ip}]
      if translation:
         addresses[0]['translation'] = translation
      else:
         addresses[0]['translation'] = 'none'
      payload = {'name':server_name,
                 'datacenter':datacenter,
                 'addresses':addresses,
                 'monitor':'/Common/bigip',
                 'product':'single-bigip'}
      if self.v13:
         del payload['product']
         addresses[0]['deviceName'] = server_name
      print self.mgmt.tm.gtm.servers.server.create(**payload)
   def create_external_dns_profile(self):
      dns_obj = self.mgmt.tm.ltm.profile.dns_s.dns
      dns_obj.create(name='external_dns',kind="tm:ltm:profile:dns:dnsstate", defaultsFrom="/Common/dns",useLocalBind="no")

   def create_internal_dns_profile(self):
      dns_obj = self.mgmt.tm.ltm.profile.dns_s.dns
      dns_obj.create(name='internal_dns',kind="tm:ltm:profile:dns:dnsstate", defaultsFrom="/Common/dns",cache="/Common/dns_cache",enableCache="yes")

   def create_external_dns_listener(self,vip):
      self.mgmt.tm.ltm.virtuals.virtual.create(name='external_dns_listener',destination='%s:53' %(vip),profiles=['/Common/external_dns'])

   def create_internal_dns_listener(self,vip,internal_network):
      self.mgmt.tm.ltm.virtuals.virtual.create(name='internal_dns_listener',destination='%s:53' %(vip),
                                               profiles=['/Common/internal_dns'],
                                               source=internal_network )

   def create_region(self,name,networks):
      # BZ501258
      #  iControl REST - Can't use PUT to modify "gtm region region-members" attributes
      subnets = 'subnet ' + " subnet ".join(networks)
      cmd = "\"tmsh create /gtm region %s region-members add { %s }\"" %(name, subnets)

      c = self.mgmt.tm.util.bash.exec_cmd('run', utilCmdArgs='-c %s' %(cmd))

   def create_topology_record(self,name):
      self.mgmt.tm.gtm.topology_s.topology.create(name=name)
      # ldns: region /Common/us-east-1-region server: pool /Common/sample_int_pool
      # ldns: not region /Common/us-east-1-region server: pool /Common/sample_ext_pool
      # ldns: region /Common/us-east-1d server: region /Common/us-east-1d

   def create_vs(self,server_name, vs_name, vs_ip_port, vs_translate_ip_port):
      s = self.mgmt.tm.gtm.servers.server.load(name=server_name,partition=self.partition)
      vs = s.virtual_servers_s

      if vs_translate_ip_port:
         (translationAddress,translationPort) = vs_translate_ip_port.split(':')      

      vs.virtual_server.create(name=vs_name,
                               destination=vs_ip_port,
                               translationAddress=translationAddress,
                               translationPort=translationPort,
                               monitor="/Common/bigip")

   def create_pool(self,pool_name,loadBalancingMode="topology",
                   alternateMode="round-robin",
                   fallbackMode="none"):
      " create pool > 12.0"
      a_obj  = self.mgmt.tm.gtm.pools.a_s.a
      p = a_obj.create(name=pool_name,
                       loadBalancingMode=loadBalancingMode,
                       alternateMode=alternateMode,
                       fallbackMode=fallbackMode)

   def create_pool_members(self,pool_name,vs_names):
      a_obj  = self.mgmt.tm.gtm.pools.a_s.a
      p = a_obj.load(name=pool_name)
      m = p.members_s.member
      for vs_name in vs_names:
         m.create(name=vs_name,partition=self.partition)

   def create_wideip(self,name,pool_names,poolLbMode='topology'):
      w = self.mgmt.tm.gtm.wideips.a_s.a
      pools = [{'name':a,"partition":self.partition} for a in pool_names]
      w1 = w.create(name=name,pools=pools,partition=self.partition,poolLbMode=poolLbMode,lastResortPool="a /%s/%s" %(self.partition,pool_names[0]))

   def gtm_add(self, peer_selfip,peer_selfip_translate=None):
      "perform gtm_add.  requires ssh"
      if not peer_selfip_translate:
         peer_selfip_translate = peer_selfip

      selfip_obj = filter(lambda a: a.address.startswith(peer_selfip_translate),self.mgmt2.tm.net.selfips.get_collection())[0]
      orig_allowService =  selfip_obj.allowService
      if 'tcp:22' not in orig_allowService and orig_allowService != 'all':
         selfip_obj.allowService += ['tcp:22']
         selfip_obj.update()
      command = 'gtm_add'
      exit_code = self._dns_expect("gtm_add", peer_selfip)
      if 'tcp:22' not in orig_allowService and orig_allowService != 'all':
         selfip_obj = self.mgmt2.tm.net.selfips.load(name=selfip_obj.name,partition=self.partition)
         selfip_obj.allowService = orig_allowService
         selfip_obj.update()
   def save_config(self):
      "perform save /sys config for LTM/GTM"
      c = self.mgmt.tm.sys.config
      c.exec_cmd('save')
      c.exec_cmd('save',name='gtm-only')

   def _debug_conn (self, conn ):
      print "Before Match:"
      print conn.before
      print "After Match:"
      print conn.after
      print ""

   def _dns_expect(self, command, peer_host):

      user = self.shell_username
      host = self.host
      peer_user = self.shell_username
      password = self.shell_password

      print_debug = 1
      if print_debug == 1:
         print "user: " + user
         print "host: " + host
         print "command: " + command
         print "peer_user: " + peer_user
         print "peer_host: " + peer_host
#         print "password: " + password



      if host == peer_host:
         print "Exiting. Not running as target and destination are the same"
         return 1


      MY_TIMEOUT = 30
      SSH_NEWKEY = 'Are you sure you want to continue connecting'
      if print_debug == 1:
         print "SSH'ing to : " + user + "@" + host
      conn = pexpect.spawn("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no " +  user + "@" + host)

      match_value = conn.expect([SSH_NEWKEY, '[Pp]assword:', pexpect.EOF, pexpect.TIMEOUT], timeout=MY_TIMEOUT);
      #print "match_value = " + str(match_value)
      if print_debug == 1:
         self._debug_conn(conn)

      time.sleep(1)
      if match_value == 0:
         if print_debug == 1:
            print "Matched new key warning"
         conn.sendline ( "yes" )
      elif match_value == 1:
         if print_debug == 1:
            print "Matched Password prompt. Sending Password"
         conn.sendline ( password )
      time.sleep(1)

      #Hopefully eventually get here
      match_value = conn.expect('\(tmos\)#', timeout=MY_TIMEOUT)

      if print_debug == 1:
         self._debug_conn(conn)

      if match_value == 0:
          #bash prompt
          #conn.expect('~ #', timeout=MY_TIMEOUT)
          #SOL14495: The bigip_add and gtm_add scripts now accept a user name
         if print_debug == 1:
            print "Matched tmsh prompt! Now adding bigip peer with command \"run gtm " + command + " -a " + peer_user + "@" + peer_host + "\"";
         conn.sendline("run gtm " + command +  " -a " + peer_user + "@" + peer_host)

      if command == "gtm_add":
          conn.expect ('Are you absolutely sure you want to do this?')
          if print_debug == 1:
             print "Confirming will wipe away this config and use peer GTM's config instead"
          conn.sendline ('y')
      time.sleep(3);

      #Otherwise will get a insecure key warning for the first attempt for either command
      match_value = conn.expect([SSH_NEWKEY, pexpect.EOF, pexpect.TIMEOUT], timeout = MY_TIMEOUT)

      if print_debug == 1:
         self._debug_conn(conn)

      if match_value == 0:
         if print_debug == 1:
            print "Matched new key warning"
         conn.sendline ( "yes" )

      #Subsequent attempts will just get a password prompt
      match_value = conn.expect([ '[Pp]assword:', pexpect.EOF, pexpect.TIMEOUT], timeout = MY_TIMEOUT)

      if print_debug == 1:
         self._debug_conn(conn)

      if match_value == 0:
         if print_debug == 1:
            print "Matched Password prompt. Sending Password"
         conn.sendline ( password )

      # Expect "==> Done <==" as sign of success
      match_value = conn.expect(['==> Done <==', '\(tmos\)#', pexpect.EOF, pexpect.TIMEOUT], timeout=MY_TIMEOUT);

      if print_debug == 1:
         self._debug_conn(conn)

      if match_value == 0:
         if print_debug == 1:
            print "Received \"==> Done <==\" : " +  "command " + command + " successful"
            print "exiting cleanly"
         return 0
      elif match_value == 1:
         if print_debug == 1:
            print "Recived tmsh prompt? Really need to check results"
         return 1
      else:
         #anything else, fail
         return 1
   

if __name__ == "__main__":
   parser = OptionParser()
   parser.add_option('-u','--user',dest='user',default='admin')
   parser.add_option('--shell_user')
   parser.add_option('--shell_password')
   parser.add_option('--host',dest='host')
   parser.add_option('--selfip',dest='selfip')
   parser.add_option('-c','--cmd',dest='cmd')
   parser.add_option('-p','--password',dest='password',default='admin')
   parser.add_option('--password-file',dest='password_file')
   parser.add_option('--datacenter',dest='datacenter')
   parser.add_option('--action',dest='action')
   parser.add_option('--server_name',dest='server_name')
   parser.add_option('--server_ip',dest='server_ip')
   parser.add_option('--server_translate_ip',dest='server_translate_ip')

   parser.add_option('--peer_user',dest='peer_user',default='admin')
   parser.add_option('--peer_host',dest='peer_host')

   parser.add_option('--shell-password-file',dest='shell_password_file')

   parser.add_option('--peer_selfip',dest='peer_selfip')
   parser.add_option('--peer_selfip_translate',dest='peer_selfip_translate')
   parser.add_option('--listener_ip')
   parser.add_option('--internal_network')
   parser.add_option('--vs_name')
   parser.add_option('--pool_name')
   parser.add_option('--name')
   parser.add_option('--vip')
   parser.add_option('--vip_translate')
   parser.add_option('--port',default=443)

   (options,args) = parser.parse_args()

   host = options.host

   username = options.user

   if options.password_file:
      password = open(options.password_file).readline().strip()
   else:
      password = options.password

   if options.shell_password_file:
      print options.shell_password_file
      shell_password = open(options.shell_password_file).readline().strip()
   else:
      shell_password = options.shell_password


   user = options.user
   host = options.host
   selfip = options.selfip
   command = options.cmd
   peer_user = options.peer_user
   peer_host = options.peer_host
   peer_selfip = options.peer_selfip
   shell_user = options.user

   if options.shell_user:
      shell_user = options.shell_user

   if not shell_password:
      shell_password = password
   print shell_user
   dns_helper = DnsHelper(host, username, password, 
                          peer_host=peer_host, 
                          peer_username=peer_user, 
                          peer_password=password, 
                          shell_username=shell_user,
                          shell_password=shell_password,
                          port=options.port)

   if options.action == 'enable_sync':
      dns_helper.enable_sync()

   elif options.action == 'add_datacenter':
      if not options.datacenter:
         raise Exception, "data center required"
      dns_helper.add_datacenter(options.datacenter)

   elif options.action == 'add_server':
      if not options.datacenter:
         raise Exception, "data center required"
      
      if not options.server_name or not options.server_ip:
         raise Exception, "server name/ip required"
      dns_helper.add_server(options.server_name, options.server_ip, options.datacenter, options.server_translate_ip)
   elif options.action == 'gtm_add':
      # enable ssh on peer host
      dns_helper.gtm_add(peer_selfip,options.peer_selfip_translate)
   elif options.action == 'save_config':
      dns_helper.save_config()
   elif options.action == 'create_dns_cache':
      dns_helper.create_dns_cache()
   elif options.action == "create_external_dns_profile":
      dns_helper.create_external_dns_profile()
   elif options.action == "create_internal_dns_profile":
      dns_helper.create_internal_dns_profile()
   elif options.action == "create_external_dns_listener":
      dns_helper.create_external_dns_listener(options.listener_ip)
   elif options.action == "create_internal_dns_listener":
      dns_helper.create_internal_dns_listener(options.listener_ip,options.internal_network)
   elif options.action == "create_vs":
      dns_helper.create_vs(options.server_name, options.vs_name, options.vip, options.vip_translate)
   elif options.action == "create_region":
      networks = options.internal_network.split(',')
      dns_helper.create_region(options.name, networks)
   elif options.action == "create_pool":
      dns_helper.create_pool(options.name)
   elif options.action == "create_pool_members":
      vs_names = options.vs_name.split(',')
      dns_helper.create_pool_members(options.name,vs_names)
   elif options.action == "create_topology_record":
      dns_helper.create_topology_record(options.name)
   elif options.action == "create_wideip":
      pool_names = options.pool_name.split(",")
      dns_helper.create_wideip(options.name, pool_names)
   
