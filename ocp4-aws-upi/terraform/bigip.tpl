#cloud-config
tmos_declared:
  enabled: true
  icontrollx_trusted_sources: false
  icontrollx_package_urls:
    - https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.20.0/f5-appsvcs-3.20.0-3.noarch.rpm
    - https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.13.0/f5-declarative-onboarding-1.13.0-5.noarch.rpm
    - https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.1.0/f5-appsvcs-templates-1.1.0-1.noarch.rpm
  do_declaration:
    schemaVersion: 1.0.0
    class: Device
    async: true
    label: Cloudinit Onboarding
    Common:
      class: Tenant
      provisioningLevels:
        class: Provision
        ltm: nominal
        gtm: nominal
      dnsServers:
        class: DNS
        nameServers:
          - 10.1.0.2
        search:
          - ec2.internal
      ntpServers:
        class: NTP
        servers:
          - 0.pool.ntp.org
          - 1.pool.ntp.org
          - 2.pool.ntp.org
      internal:
        class: VLAN
        mtu: 9001
        interfaces:
          - name: 1.2
            tagged: false
      internal-self:
        class: SelfIp
        address: 10.1.20.240/24
        vlan: internal
        allowService: all
        trafficGroup: traffic-group-local-only
      internal-float:
        class: SelfIp
        address: 10.1.20.242/24
        vlan: internal
        allowService: all
        trafficGroup: traffic-group-1
      external:
        class: VLAN
        mtu: 9001
        interfaces:
          - name: 1.1
            tagged: false
      external-self:
        class: SelfIp
        address: 10.1.10.240/24
        vlan: external
        allowService: none
        trafficGroup: traffic-group-local-only
      external-float:
        class: SelfIp
        address: 10.1.10.242/24
        vlan: external
        allowService: none
        trafficGroup: traffic-group-1
      default:
        class: Route
        gw: 10.1.10.1
        network: default
        mtu: 1500
  extension_services:
    service_operations:
    - extensionType: as3
      type: url
      value: file:///var/tmp/as3_example.json	
  post_onboard_enabled: true
  post_onboard_commands:
    # not recommended to set password via cloud-init in AWS
    # this is NOT a secure method, used for demo purposes only
    - tmsh modify auth user admin { password ${password} }
    - tmsh modify auth user admin shell bash
    - tmsh save sys config
