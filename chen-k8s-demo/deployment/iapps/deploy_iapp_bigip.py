#!/usr/bin/python
# Copyright (c) 2017 F5 Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
# deploy_iapp_bigip.py -- Deploy an iApp to a BIG-IP system using the iControl-REST API
# Documentation: see README.deploy_iapp_bigip
import requests

try:
	requests.packages.urllib3.disable_warnings()
except:
	pass

import json
import argparse
import os
import sys
import pprint
import time
pp = pprint.PrettyPrinter(indent=2)

'''
Recursively process a JSON object.
Parent files are specified by the 'parent' key in the JSON object
Values in the 'child' file take precedence
'''
def process_file(parent, child, indent):
	print "[info] %sprocessing parent file \"%s\"" % (indent, parent)

	try:
		parent_file = open(parent)
	except IOError as error:
		print "[error] Open of parent JSON template \"%s\" failed: %s" % (parent, error)
		sys.exit(1)

	try:
		parentdict = json.load(parent_file)
	except (ValueError, NameError) as error:
		print "[error] JSON format error in template \"%s\": %s" % (parent, error)
		sys.exit(1)

	parent_file.close()

	# Recursion happens here
	if 'parent' in parentdict:
		parentdict = process_file(parentdict["parent"], parentdict, indent + " ")

	# Process the child objects 'strings' and 'tables' keys.
	child_strings = {}
	child_tables = {}
	debug("[%s] starting merge" % (parent))
	if 'strings' in child:
		for string in child["strings"]:
			k, v = string.popitem()
			debug("[%s] child: %s" % (parent, k))
			child_strings[k] = v

	if 'tables' in child:
		i = 0
		for table in child["tables"]:
			debug("[%s] iapptable %s" % (parent, table["name"]))
			child_tables[table["name"]] = i
			i += 1

	# Merge with the parent dictionary giving precedence to the child's values
	if 'strings' in parentdict:
		for string in parentdict["strings"]:
			k, v = string.popitem()
			if k in child_strings.keys():
				string[k] = child_strings[k]
			 	debug("[%s] OVERRIDE: %s: %s" % (parent, k, string[k]))
			else:
			 	string[k] = v

	if 'tables' in parentdict:
		i = 0
		for table in parentdict["tables"]:
			if table["name"] in child_tables.keys():
				debug("[%s] OVERRIDE TABLE: %s" % (parent, table["name"]))
				parentdict["tables"][i] = child["tables"][child_tables[table["name"]]]
			i += 1

	if 'lists' in parentdict:
		i = 0
		for alist in parentdict["lists"]:
			if alist["name"] in child_tables.keys():
				debug("[%s] OVERRIDE LIST: %s" % (parent, alist["name"]))
				parentdict["lists"][i] = child["lists"][child_tables[alist["name"]]]
			i += 1

	# Inherit any other top level keys
	for topitem in child.keys():
		debug("topitem=%s" % topitem)
		if not topitem in ["tables", "strings"]:
			parentdict[topitem] = child[topitem]

	return parentdict

def debug(msg):
	if args.debug:
		print "DEBUG: %s" % (msg)

def check_final_deploy(istat_key):
	if args.nocheck:
		return(1)

	current_time = int(time.time())
	bashurl   = "https://%s/mgmt/tm/util/bash" % (args.host)
	istat_payload = { "command":"run",
					 "utilCmdArgs":"-c 'tmsh run cli script appsvcs_get_istat \"%s\"'" % (istat_key)
	               }

	for i in range(args.checknum):
		print "[info] checking for deployment completion (%s/%s)..." % ((i+1), args.checknum)
		resp = s.post(bashurl, data=json.dumps(istat_payload))
		if resp.status_code != requests.codes.ok:
			print "ERROR: %s" % (resp.json())
			sys.exit(1)

		respdict = json.loads(resp.text)

		result = respdict.get('commandResult')
		result = result.replace('\n','')
		debug("[check_deploy] current_time=%s result=%s" % (current_time, result))
		if result.startswith("FINISHED_"):
			parts = result.split('_')
			fin_time = int(parts[1])
			if fin_time > current_time:
				return(1)
		time.sleep(args.checkwait)

	return(0)

# Setup and process arguments
parser = argparse.ArgumentParser(description='Script to deploy an iApp to a BIG-IP device')
parser.add_argument("host",             help="The IP/Hostname in <host>[:<port>] format of the BIG-IP device")
parser.add_argument("json_template",    help="The JSON iApp definition file")
parser.add_argument("-u", "--username", help="The BIG-IP username")
parser.add_argument("-p", "--password", help="The BIG-IP password")
parser.add_argument("-d", "--dontsave", help="Don't automatically save the config", action="store_true")
parser.add_argument("-r", "--redeploy", help="Redeploy an existing iApp", action="store_true")
parser.add_argument("-D", "--debug",    help="Enable debug output", action="store_true")
parser.add_argument("-n", "--nocheck",  help="Don't check for deployment completion", action="store_true")
parser.add_argument("-c", "--checknum", help="Number of times to check for deployment completion", default=10, type=int)
parser.add_argument("-w", "--checkwait",help="Delay in seconds between each deployment completion check", default=6, type=int)
parser.add_argument("--password-file",   help="The BIG-IP password stored in a file", dest='password_file')
parser.add_argument("--iapp_name",   help="iapp_name (optional)")
parser.add_argument("--strings",   help="override variables, i.e. --strings=pool_addr,172.16.0.231")
parser.add_argument("--pool_members",   help="common separated list of ip:[port] will replace \"0.0.0.0\" members")

args = parser.parse_args()

print "[info] processing template \"%s\"" % (args.json_template)

try:
	iapp_file = open(args.json_template)
except IOError as error:
	print "[error] Open of JSON template \"%s\" failed: %s" % (args.json_template, error)
	sys.exit(1)

try:
	iapp = json.load(iapp_file)
except (ValueError, NameError) as error:
	print "[error] JSON format error in template \"%s\": %s" % (args.json_template, error)
	sys.exit(1)

iapp_file.close()

if args.strings:
        list_of_strings = args.strings.split(",")
        for str_item in list_of_strings:
                (k,v) = str_item.split('=')
                iapp["strings"].append({k:v})

if args.pool_members:

        # replace anything existing
        members = args.pool_members.split(",")
        row_template =  [ "0", "0.0.0.0", "80", "0", "1", "0", "enabled", "none"]
        rows = []
        for member in members:
                port = "80"
                new_row = row_template[:]
                if ":" in member:
                        parts = member.split(":")
                        if len(parts) == 2:
                                (ip,port) = parts
                                new_row[1] = ip
                                new_row[2] = port
                        elif len(parts) == 8:
                                new_row = parts
                else:
                        ip = member
                        new_row[2] = port
                rows.append({'row':new_row})

        new_pools = {u'columnNames': [u'Index', u'IPAddress', u'Port', u'ConnectionLimit', u'Ratio', u'PriorityGroup', u'State', u'AdvOptions'], 
                     u'rows': rows,
                     u'name': u'pool__Members'}

        if 'tables' in iapp:
                iapp['tables'].append(new_pools)
        else:
                iapp['tables'] = [new_pools]

if 'parent' in iapp:
	final = process_file(iapp["parent"], iapp, " ")
else:
	final = iapp

if args.username:
	if 'username' in final:
		print "[info] Username found in JSON but specified on CLI, using CLI value"
	final["username"] = args.username

if args.password:
	if 'password' in final:
		print "[info] Password found in JSON but specified on CLI, using CLI value"
	final["password"] = args.password
if args.password_file:
        if 'password' in final:
                print "[info] Password found in JSON but specified in CLI, using CLI value"
        final["password"] = open(args.password_file).readline().strip()

# Required fields
required = ['name','template_name','partition','username','password','inheritedDevicegroup','inheritedTrafficGroup','deviceGroup','trafficGroup']

if args.iapp_name:
        final["name"] = args.iapp_name

for item in required:
	if not item in final:
		print "[error] The required key \"%s\" was not found in the JSON template (or it's parent(s))" % (item)
		sys.exit(1)

debug("final=%s" % pp.pformat(final))

# Set our REST urls
iapp_url       = "https://%s/mgmt/tm/sys/application/service" % (args.host)
save_url       = "https://%s/mgmt/tm/sys/config" % (args.host)
template_url   = "https://%s/mgmt/tm/sys/application/template?$select=name" % (args.host)
iapp_exist_url = "%s/~%s~%s.app~%s" % (iapp_url, final["partition"], final["name"], final["name"])
bash_url       = "https://%s/mgmt/tm/util/bash" % (args.host)

# Create request session, set credentials, allow self-signed SSL cert
s = requests.session()
s.auth = (final["username"], final["password"])
s.verify = False

time_payload = {
    "command":"run",
    "utilCmdArgs":"-c 'date +%s'"
}

resp = s.post(bash_url, data=json.dumps(time_payload))

if resp.status_code == 401:
    print "[error] Authentication to %s failed" % (args.host)
    sys.exit(1)


systimejson = json.loads(resp.text)
systime = systimejson.get('commandResult')
systime = systime.replace('\n','')

debug("[check_time] %s" % systime)

delta = time.time() - int(systime)
debug("[check_time] delta=%s" % delta)

if delta > 10:
    print "[error] Time delta between local system and BIG-IP is %s.  Limit is 10 seconds.  Please ensure time is synced" % delta
    sys.exit(1)

resp = s.get(template_url)
templates = resp.json();

tmpllist = []
for item in templates["items"]:
	if item["name"].startswith("appsvcs_integration_"):
		debug("[template_list] found template named %s" % (item["name"]))
		tmpllist.append(item["name"])

debug("[template_select] specified=%s" % (final["template_name"]))
if final["template_name"] == "latest":
	tmpllist.sort()
	final["template_name"] = tmpllist.pop()
	debug("[template_select] selected=%s" % (final["template_name"]))
else:
	if not final["template_name"] in tmpllist:
		print "[error] iApp template \"%s\" is not installed on BIG-IP host %s" % (final["template_name"], args.host)
		sys.exit(1)

deploy_payload = {
    "inheritedDevicegroup": final["inheritedDevicegroup"],
    "inheritedTrafficGroup": final["inheritedTrafficGroup"],
    "deviceGroup": final["deviceGroup"],
    "trafficGroup": final["trafficGroup"],
    "template": final["template_name"],
    "partition": final["partition"],
    "name": final["name"],
    "variables": [],
    "tables": [],
    "lists":[]
}

        
                
for string in final["strings"]:
	k, v = string.popitem()
	deploy_payload["variables"].append({"name":k, "value":v})

deploy_payload["tables"] = final["tables"]
deploy_payload["lists"] = final["lists"]

# Check to see if the template with the name specified in the arguments exists on the BIG-IP device
debug("exist_url=%s" % iapp_exist_url)
resp = s.get(iapp_exist_url)

# The template exists and the -o argument (overwrite) was not specified.  Print error and exit
if resp.status_code == 200 and not args.redeploy:
	print "[error] An iApp deployment named \"%s\" already exists on BIG-IP \"%s\".  To redeploy please specify the '-r' flag" % (final["name"], args.host)
	sys.exit(1)

istat_key = "sys.application.service /%s/%s.app/%s string deploy.postdeploy_final" % (deploy_payload.get('partition'), deploy_payload.get('name'), deploy_payload.get('name'))
# iApp deployment does not already exist, create it
if resp.status_code == 404:
 	# Send the REST call to create the template and print outcome
	debug("deploy_payload=%s" % json.dumps(deploy_payload))
	resp = s.post(iapp_url, data=json.dumps(deploy_payload))
	debug("deploy resp=%s" % (pp.pformat(json.loads(resp.text))))
	if resp.status_code != requests.codes.ok:
		print "[error] iApp deployment failed: %s" % (resp.json())
		sys.exit(1)
	if check_final_deploy(istat_key):
		print "[success] iApp \"%s\" deployed on BIG-IP \"%s\"" % (final["name"], args.host)
	else:
		print "[error] iApp deployment might have failed.  Please check /var/tmp/scriptd.out on the device"
		sys.exit(1)

# iApp deployment exists and args.redeploy (-r) is TRUE so we will redeploy
else:
	del deploy_payload["inheritedDevicegroup"]
	del deploy_payload["inheritedTrafficGroup"]
	del deploy_payload["deviceGroup"]
	del deploy_payload["trafficGroup"]
	deploy_payload["execute-action"] = "definition"

	debug("redeploy_payload=%s" % pp.pformat(deploy_payload))
	resp = s.put(iapp_exist_url, data=json.dumps(deploy_payload))
	debug("redeploy resp=%s" % (pp.pformat(json.loads(resp.text))))
	if resp.status_code != requests.codes.ok:
		print "[error] iApp re-deployment failed: %s" % (resp.json())
		sys.exit(1)

	if check_final_deploy(istat_key):
		print "[success] iApp \"%s\" re-deployed on BIG-IP \"%s\"" % (final["name"], args.host)
	else:
		print "[error] iApp deployment might have failed.  Please check /var/tmp/scriptd.out on the device"
		sys.exit(1)

# Save the config (unless -d option was specified)
save_payload = { "command":"save" }
if not args.dontsave:
	resp = s.post(save_url, data=json.dumps(save_payload))
	if resp.status_code != requests.codes.ok:
		print "[error] save failed: %s" % (resp.json())
		sys.exit(1)
	else:
		print "[success] Config saved"

sys.exit(0)
