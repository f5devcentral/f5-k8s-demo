section intro {
	message hello
}

section iapp {
	choice strictUpdates default "enabled" {
		"enabled",
		"disabled"
	}
	choice appStats default "enabled" {
		"enabled",
		"disabled"
	}
	string mode display "large" default "auto"
	string logLevel display "large" default "7"
	string routeDomain display "large" default "auto"
	choice asmDeployMode display "large" default "preserve-bypass" {
		"preserve-bypass",
		"preserve-block",
		"redeploy-bypass",
		"redeploy-block"
	}
	choice apmDeployMode display "large" default "preserve-bypass" {
		"preserve-bypass",
		"preserve-block",
		"redeploy-bypass",
		"redeploy-block"
	}
}

section pool {
	string addr required display "large" validator "IpAddress" default ""
	string mask required display "large" validator "IpAddress" default "255.255.255.255"
	string port required display "small" validator "PortNumber" default ""
	string DefaultPoolIndex display "small" validator "NonNegativeNumber" default "0"
	table Pools {
		string Index display "small" validator "NonNegativeNumber" default "0"
		string Name display "medium" default ""
		string Description display "medium" default ""
		choice LbMethod display "medium" default "round-robin" {
			"dynamic-ratio-member",
			"dynamic-ratio-node",
			"fastest-app-response",
			"fastest-node",
			"least-connections-member",
			"least-connections-node",
			"least-sessions",
			"observed-member",
			"observed-node",
			"predictive-member",
			"predictive-node",
			"round-robin",
			"ratio-member",
			"ratio-node",
			"ratio-session",
			"ratio-least-connections-member",
			"ratio-least-connections-node",
			"weighted-least-connections-member"
		}
		string Monitor display "medium" default ""
		string AdvOptions display "medium" default ""
	}
	string MemberDefaultPort display "small" default ""
	table Members {
		string Index display "small" validator "NonNegativeNumber" default "0"
		editchoice IPAddress display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list ltm node]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
		string Port display "small" default "80"
		string ConnectionLimit display "medium" default "0"
		string Ratio display "small" default "1"
		string PriorityGroup display "small" default "0"
		choice State display "large"  default "enabled" {
			"enabled",
			"drain-disabled",
			"disabled"
		}
		string AdvOptions display "medium"
	}
}

section monitor {
	table Monitors {
		string Index display "small" validator "NonNegativeNumber" default "0"
		string Name display "medium" default ""
		string Type display "medium" default ""
		string Options display "medium" default ""
	}
}

section vs {
	table Listeners {
		string Listener display "large"
		string Destination display "medium" default ""
	}
	string Name display "xxlarge" default ""
	string Description display "xxlarge" default ""
	choice RouteAdv display "medium" default "disabled" {
		"disabled",
		"all_vs",
		"any_vs",
		"always"
	}
	string SourceAddress display "large" default "0.0.0.0/0"
	string IpProtocol display "small" default "tcp"
	string ConnectionLimit display "medium" default "0"
	editchoice ProfileClientProtocol display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile tcp} {ltm profile udp} {ltm profile fastl4}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileServerProtocol display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile tcp} {ltm profile udp} {ltm profile fastl4}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileHTTP display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile http}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileOneConnect display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile one-connect}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileCompression display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile http-compression}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	string ProfileAnalytics display "large" default ""
	editchoice ProfileRequestLogging display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile request-log}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileDefaultPersist display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm persistence cookie} {ltm persistence dest-addr} {ltm persistence hash} {ltm persistence msrdp} {ltm persistence sip} {ltm persistence source-addr} {ltm persistence ssl} {ltm persistence universal}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileFallbackPersist display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm persistence cookie} {ltm persistence dest-addr} {ltm persistence hash} {ltm persistence msrdp} {ltm persistence sip} {ltm persistence source-addr} {ltm persistence ssl} {ltm persistence universal}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice SNATConfig display "large" default "automap" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm snatpool}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileServerSSL display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile server-ssl}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileClientSSL display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm profile client-ssl}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileClientSSLCert display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {sys file ssl-cert}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileClientSSLKey display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {sys file ssl-key}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileClientSSLChain display "large" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {sys file ssl-cert}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	string ProfileClientSSLCipherString display "xxlarge" default "DEFAULT"
	string ProfileClientSSLAdvOptions display "xxlarge" default ""
	editchoice ProfileSecurityLogProfiles display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {security log profile}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileSecurityIPBlacklist display "large"  default "none" {
		"none",
		"enabled-block",
		"enabled-log"
	}
	editchoice ProfileSecurityDoS display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {security dos profile}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileAccess display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {apm profile access}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	editchoice ProfileConnectivity display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {apm profile connectivity}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	string ProfilePerRequest display "xxlarge" default ""
	choice OptionSourcePort display "large"  default "preserve" {
		"preserve",
		"preserve-strict",
		"change"
	}
	choice OptionConnectionMirroring default "disabled" {
		"enabled",
		"disabled"
	}
	editchoice Irules display "xxlarge" default "" tcl {
		tmsh::cd /
		set results ""
	    set cmds [list {ltm rule}]
	    foreach cmd $cmds {
	      set objs [list]
	      set objs_status [catch {tmsh::get_config $cmd recursive} objs]
	      if { $objs_status == 1 } { continue }
	      foreach obj $objs {
	      	set name [string map {"\"" ""} [tmsh::get_name $obj]]
	      	if { $name ne "" } {
		        append results "/$name"
		        append results "\n"
		    }
	      }
	    }
	    return $results
	}
		
	table BundledItems {
		editchoice Resource display "large"  {
			"** no bundled items **"
		}
	}
	string AdvOptions display "xxlarge" default ""
	string AdvProfiles display "xxlarge" default ""
	string AdvPolicies display "xxlarge" default ""
	string VirtualAddrAdvOptions display "xxlarge" default ""
}

section l7policy {
	editchoice strategy display "large" default "/Common/first-match" {
		"/Common/first-match",
		"/Common/best-match",
		"/Common/all-match"
	}
	string defaultASM display "large" default "bypass"
	string defaultL7DOS display "large" default "bypass"
	table rulesMatch {
		string Group display "small" default ""
		editchoice Operand display "xlarge" {
			"client-ssl/request/cipher",
			"client-ssl/request/cipher-bits",
			"client-ssl/request/protocol",
			"client-ssl/response/cipher",
			"client-ssl/response/cipher-bits",
			"client-ssl/response/protocol",
			"http-basic-auth/request/username",
			"http-basic-auth/request/password",
			"http-cookie/request/all/name/&lt;name&gt;",
			"http-header/request/all/name/&lt;name&gt;",
			"http-header/request/all/name/&lt;name&gt;",
			"http-host/request/all",
			"http-host/request/host",
			"http-host/request/port",
			"http-method/request/all",
			"http-referer/request/all",
			"http-referer/request/extension",
			"http-referer/request/host",
			"http-referer/request/path",
			"http-referer/request/path-segment/index/&lt;index&gt;",
			"http-referer/request/port",
			"http-referer/request/query-parameter/name/&lt;name&gt;",
			"http-referer/request/scheme",
			"http-referer/request/unnamed-query-parameter/index/&lt;index&gt;",
			"http-set-cookie/response/domain/name/&lt;name&gt;",
			"http-set-cookie/response/expiry/name/&lt;name&gt;",
			"http-set-cookie/response/path/name/&lt;name&gt;",
			"http-set-cookie/response/value/name/&lt;name&gt;",
			"http-set-cookie/response/version/name/&lt;name&gt;",
			"http-status/response/all",
			"http-status/response/code",
			"http-status/response/text",
			"http-uri/request/all",
			"http-uri/request/extension",
			"http-uri/request/host",
			"http-uri/request/path",
			"http-uri/request/path-segment/index/&lt;index&gt;",
			"http-uri/request/port",
			"http-uri/request/query-parameter/name/&lt;name&gt;",
			"http-uri/request/scheme",
			"http-uri/request/unnamed-query-parameter/index/&lt;index&gt;",
			"http-version/request/all",
			"http-version/request/major",
			"http-version/request/minor",
			"http-version/request/protocol",
			"http-version/response/all",
			"http-version/response/major",
			"http-version/response/minor",
			"http-version/response/protocol",
			"ssl-cert/ssl-server-handshake/common-name/index/&lt;index&gt;",
			"ssl-extension/ssl-client-hello/alpn",
			"ssl-extension/ssl-client-hello/npn",
			"ssl-extension/ssl-client-hello/server-name",
			"ssl-extension/ssl-server-hello/alpn",
			"ssl-extension/ssl-server-hello/npn",
			"ssl-extension/ssl-server-hello/server-name",
			"tcp/request/mss/internal",
			"tcp/request/port/internal",
			"tcp/request/port/local",
			"tcp/request/route-domain/internal",
			"tcp/request/rtt/internal",
			"tcp/request/vlan/internal",
			"tcp/request/vlan-id/internal"
		}
		choice Negate display "small" default "no" {
			"no",
			"yes"
		}
		choice Condition display "large" {
			"equals",
			"starts-with",
			"ends-with",
			"contains",
			"greater",
			"greater-or-equal",
			"less",
			"less-or-equal"
		}
		string Value display "large" default ""
		choice CaseSensitive display "small" default "no" {
			"no",
			"yes"
		}
		choice Missing display "small" default "no" {
			"no",
			"yes"
		}
	}
	table rulesAction {
		string Group display "small" default ""
		editchoice Target display "xlarge" {
			"asm/request/enable/policy",
			"asm/request/disable",
			"cache/request/enable/pin",
			"cache/request/disable",
			"cache/response/enable/pin",
			"cache/respones/disable",
			"compress/request/enable",
			"compress/request/disable",
			"compress/response/enable",
			"compress/response/disable",
			"decompress/request/enable",
			"decompress/request/disable",
			"decompress/response/enable",
			"decompress/response/disable",
			"forward/request/reset",
			"forward/request/select/clone-pool",
			"forward/request/select/member",
			"forward/request/select/nexthop",
			"forward/request/select/node",
			"forward/request/select/pool",
			"forward/request/select/rateclass",
			"forward/request/select/snat",
			"forward/request/select/snatpool",
			"forward/request/select/vlan",
			"forward/request/select/vlan-id",
			"http/request/enable",
			"http/request/disable",
			"http-cookie/request/insert/name,value",
			"http-cookie/request/remove/name",
			"http-header/request/insert/name,value",
			"http-header/request/remove/name",
			"http-header/request/replace/name,value",
			"http-header/response/insert/name,value",
			"http-header/response/remove/name",
			"http-header/response/replace/name,value",
			"http-host/request/replace/value",
			"http-referer/request/insert/value",
			"http-referer/request/remove",
			"http-referer/request/replace/value",
			"http-reply/request/redirect/location",
			"http-reply/response/redirect/location",
			"http-set-cookie/response/insert/name,domain,path,value",
			"http-set-cookie/response/remove/name",
			"http-uri/response/replace/path,query-string,value",
			"l7dos/request/enable/from-profile",
			"l7dos/request/disable",
			"log/request/write/message",
			"log/response/write/message",
			"request-adapt/request/enable/internal-virtual-server",
			"request-adapt/request/disable",
			"request-adapt/response/enable/internal-virtual-server",
			"request-adapt/response/disable",
			"response-adapt/request/enable/internal-virtual-server",
			"response-adapt/request/disable",
			"response-adapt/response/enable/internal-virtual-server",
			"request-adapt/response/disable",
			"server-ssl/request/enable",
			"server-ssl/request/disable",
			"tcl/request/set-variable/name,expression",
			"tcl/response/set-variable/name,expression",
			"tcl/ssl-client-hello/set-variable/name,expression",
			"tcl/ssl-server-handshake/set-variable/name,expression",
			"tcl/ssl-server-hello/set-variable/name,expression",
			"tcp-nagle/request/enable",
			"tcp-nagle/request/disable"
		}
		string Parameter display "large" default ""
	}
}

section feature {
	choice statsTLS display "medium" default "auto" {
		"auto",
		"enabled",
		"disabled"
	}
	choice statsHTTP display "medium" default "auto" {
		"auto",
		"enabled",
		"disabled"
	}
	choice insertXForwardedFor display "medium" default "auto" {
		"auto",
		"enabled",
		"disabled"
	}
	choice redirectToHTTPS display "medium" default "auto" {
		"auto",
		"enabled",
		"disabled"
	}
	choice sslEasyCipher display "medium" default "disabled" {
		"compatible",
		"medium",
		"high",
		"tls_1.2",
		"tls_1.1+1.2",
		"disabled"
	}
	editchoice securityEnableHSTS display "xlarge" default "disabled" {
		"disabled",
		"enabled",
		"enabled-preload",
		"enabled-subdomain",
		"enabled-preload-subdomain"
	}
	choice easyL4Firewall display "xlarge" default "auto" {
		"auto",
		"base",
		"base+ip_blacklist_block",
		"base+ip_blacklist_log",
		"disabled"
	}
	table easyL4FirewallBlacklist {
		string CIDRRange display "large"
	}
	table easyL4FirewallSourceList {
		string CIDRRange display "large" default "0.0.0.0/0"
	}
}

section extensions {
	string Field1 display "xxlarge" default ""
	string Field2 display "xxlarge" default ""
	string Field3 display "xxlarge" default ""
}


text {
	intro "F5 Application Services Integration iApp v2.0.003 (Community Edition)"
	intro.hello "Introduction" "Please complete the following template"

	iapp "iApp Options"
	iapp.strictUpdates "iApp: Strict Updates"
	iapp.appStats "iApp: Statistics Handler Creation"
	iapp.mode "iApp: Mode"
	iapp.logLevel "iApp: Log Level"
	iapp.routeDomain "iApp: Route Domain"
	iapp.asmDeployMode "iApp: ASM: Deployment Mode"
	iapp.apmDeployMode "iApp: APM: Deployment Mode"

	pool "Virtual Server Listener & Pool Configuration"
	pool.addr "Virtual Server: Address"
	pool.mask "Virtual Server: Mask"
	pool.port "Virtual Server: Port"
	pool.DefaultPoolIndex "Virtual Server: Default Pool Index"
	pool.Pools "Pool: Pool Table"
	pool.Pools.Index "Index:"
	pool.Pools.Name "Name:"
	pool.Pools.Description "Description:"
	pool.Pools.LbMethod "LB Method:"
	pool.Pools.Monitor "Monitor(s):"
	pool.Pools.AdvOptions "Adv Options:"
	pool.MemberDefaultPort "Pool: Member Default Port"
	pool.Members "Pool: Members"
	pool.Members.Index "Pool Idx:"
	pool.Members.IPAddress "IP/Node Name:"
	pool.Members.Port "Port:"
	pool.Members.ConnectionLimit "Connection Limit:"
	pool.Members.Ratio "Ratio:"
	pool.Members.PriorityGroup "Priority Group:"
	pool.Members.State "State:"
	pool.Members.AdvOptions "Adv Options:"

	monitor "Pool Monitor(s) Configuration"
	monitor.Monitors "Monitor: Monitor Table"
	monitor.Monitors.Index "Index:"
	monitor.Monitors.Name "Name:"
	monitor.Monitors.Type "Type:"
	monitor.Monitors.Options "Options:"

	vs "Virtual Server Configuration"
	vs.Listeners "Virtual Server: Additional Listeners"
	vs.Listeners.Listener "Listener:"
	vs.Listeners.Destination "Destination"
	vs.Name "Virtual Server: Name"
	vs.Description "Virtual Server: Description"
	vs.RouteAdv "Virtual Server: Route Advertisement"
	vs.SourceAddress "Virtual Server: Source Address"
	vs.IpProtocol "Virtual Server: IP Protocol"
	vs.ConnectionLimit "Virtual Server: Virtual Server Connection Limit (0=unlimited)"
	vs.ProfileClientProtocol "Virtual Server: Client-side L4 Protocol Profile"
	vs.ProfileServerProtocol "Virtual Server: Server-side L4 Protocol Profile"
	vs.ProfileHTTP "Virtual Server: HTTP Profile"
	vs.ProfileOneConnect "Virtual Server: OneConnect Profile"
	vs.ProfileCompression "Virtual Server: Compression Profile"
	vs.ProfileAnalytics "Virtual Server: Analytics Profile"
	vs.ProfileRequestLogging "Virtual Server: Request Logging Profile"
	vs.ProfileDefaultPersist "Virtual Server: Default Persistence Profile"
	vs.ProfileFallbackPersist "Virtual Server: Fallback Persistence Profile"
	vs.SNATConfig "Virtual Server: SNAT Configuration (enter SNAT pool name, 'automap' or leave blank to disable SNAT)"
	vs.ProfileServerSSL "Virtual Server: Server SSL Profile"
	vs.ProfileClientSSL "Virtual Server: Client SSL Profile"
	vs.ProfileClientSSLCert "Virtual Server: Client SSL Certificate"
	vs.ProfileClientSSLKey "Virtual Server: Client SSL Key"
	vs.ProfileClientSSLChain "Virtual Server: Client SSL Certificate Chain"
	vs.ProfileClientSSLCipherString "Virtual Server: Client SSL Cipher String"
	vs.ProfileClientSSLAdvOptions "Virtual Server: Client SSL Advanced Options"
	vs.ProfileSecurityLogProfiles "Virtual Server: Security Logging Profiles"
	vs.ProfileSecurityIPBlacklist "Virtual Server: IP Blacklist Profile"
	vs.ProfileSecurityDoS "Virtual Server: Security: DoS Profile"
	vs.ProfileAccess "Virtual Server: Access Profile"
	vs.ProfileConnectivity "Virtual Server: Connectivity Profile"
	vs.ProfilePerRequest "Virtual Server: Per-Request Profile"
	vs.OptionSourcePort "Virtual Server: Source Port Behavior"
	vs.OptionConnectionMirroring "Virtual Server: Connection Mirroring"
	vs.Irules "Virtual Server: iRules (to specify multiple iRules seperate with a comma ex: irule1,irule2,irule3)"
	vs.BundledItems "Virtual Server: Bundled Items"
	vs.BundledItems.Resource "Resource:"
	vs.AdvOptions "Virtual Server: Advanced Options"
	vs.AdvProfiles "Virtual Server: Advanced Profiles"
	vs.AdvPolicies "Virtual Server: Advanced Policies"
	vs.VirtualAddrAdvOptions "Virtual Address: Advanced Options"

	l7policy "L7 Traffic Policy"
	l7policy.strategy "L7 Policy: Match Strategy"
	l7policy.defaultASM "L7 Policy: Default ASM Policy"
	l7policy.defaultL7DOS "L7 Policy: Default L7 DoS Policy"
	l7policy.rulesMatch "L7 Policy: Rules: Matching"
	l7policy.rulesMatch.Group "Group:"
	l7policy.rulesMatch.Operand "Operand:"
	l7policy.rulesMatch.Negate "Negate:"
	l7policy.rulesMatch.Condition "Condition:"
	l7policy.rulesMatch.Value "Value:"
	l7policy.rulesMatch.CaseSensitive "Case Sensitive:"
	l7policy.rulesMatch.Missing "Missing:"
	l7policy.rulesAction "L7 Policy: Rules: Action"
	l7policy.rulesAction.Group "Group:"
	l7policy.rulesAction.Target "Target:"
	l7policy.rulesAction.Parameter "Parameter:"

	feature "L4-7 Helpers"
	feature.statsTLS "TLS/SSL: Stats Reporting"
	feature.statsHTTP "HTTP: Stats Reporting"
	feature.insertXForwardedFor "HTTP: Insert X-Forwarded-For Header"
	feature.redirectToHTTPS "HTTP: Security: Create HTTP(80)->HTTPS(443) Redirect"
	feature.sslEasyCipher "TLS/SSL: Easy Cipher String (overrides VS section setting)"
	feature.securityEnableHSTS "HTTP: Security: Enable HTTP Strict Transport Security (only valid if ClientSSL is configured)"
	feature.easyL4Firewall "Security: Firewall: Configure L4 Firewall Policy"
	feature.easyL4FirewallBlacklist "Security: Firewall: Static Blacklisted Addresses (CIDR Format)"
	feature.easyL4FirewallBlacklist.CIDRRange "CIDR Block:"
	feature.easyL4FirewallSourceList "Security: Firewall: Static Allowed Source Addresses (CIDR Format)"
	feature.easyL4FirewallSourceList.CIDRRange "CIDR Block:"

	extensions "Custom Extensions Section"
	extensions.Field1 "Extensions: Field 1"
	extensions.Field2 "Extensions: Field 2"
	extensions.Field3 "Extensions: Field 3"

}
