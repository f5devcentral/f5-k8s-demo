{{/* Basic HTTP */}}
{{- define "f5demo.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.http.v1",
               "pool": "{{ .name }}_pool",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"}
             },
             "{{ .name }}_pool": {
                "class": "Pool",
                "monitors": [
                   "http"
                ],
                "members": [{
                   "servicePort": 80,
                   "serverAddresses": [
                   ]
                }]
             }
{{- end }}
{{- define "f5demo.sni.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualPort }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.sni.http.v1",
               "pool": "{{ .pool }}",
               "clientTLS": {"bigip":"/Common/serverssl"},
               "iRules": ["/Common/Shared/Host_Header_To_Sni", "/Common/Shared/Proxy_Protocol_Send"]
             }
{{- end }}
{{- define "f5demo.waf.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [{{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.waf.http.v1",	       
               "pool": {{ if  .pool }}{{ .pool |quote }}{{ else }}"{{ .name }}_pool"{{ end }},
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "policyWAF":{{if .policyWAF }}{{ .policyWAF}}{{ else }}{"bigip":"/Common/linux-low"}{{ end }},
               "securityLogProfiles": [
               {
                 "bigip": "/Common/Log all requests"
               }
               ]
             }{{ if not .pool}},
             "{{ .name }}_pool": {
                "class": "Pool",
                "monitors": [
                   "http"
                ],
                "members": [{
                   "servicePort": 80,
                   "serverAddresses": [
                   ]
                }]
             }{{ end }}
{{- end }}
{{- define "f5demo.hostnamerouter.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.hostnamerouter.http.v1",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "policyEndpoint": "{{- .name}}_policy_endpoint"
             },
             "{{- .name }}_policy_endpoint": {
                "class": "Endpoint_Policy",
        "rules": [
           {{- $local := dict "cnt" 0 }}	
           {{- $local := dict "first" true  }}       
           {{- range .targets }}
           {{- range $key, $val :=. }}
           {{- if not $local.first }},{{- end }}
           {{- $_ := set $local "first" false  }}
           {{- $_ := set $local "cnt" ($local.cnt |add1)  }}	   	   
           {
          "name": "forward_to_{{$local.cnt}}",
          "conditions": [{
            "type": "httpHeader",
            "all": {
              "operand": "{{ if hasPrefix "*" $key }}ends-with{{ else }}equals{{end}}",
              "values": ["{{ trimPrefix "*" $key }}"],
              "caseSensitive": false
            },
            "name":"host"
          }
           ],
          "actions": [
            {
            "type": "forward",
            "event": "request",
            "select": {
              "service": {"use":"{{ $val }}"}
            }
          }]
        }
           {{- end }}
           {{- end }}
           {{- $local := dict "first" true  }}       
           {{- $local := dict "cnt" 0 }}
           {{- range .redirects }}
           {{- range $key, $val :=. }}
           {{- $_ := set $local "cnt" ($local.cnt |add1)  }}
           {{- if not $local.first }},{{else}}{{ if $.targets }},{{end}}{{- end }}
           {{- $_ := set $local "first" false  }}
           {{- $parts := split "/" $key }}
           {{- $partslist := splitList "/" $key }}
            {
          "name": "redirect_{{$local.cnt}}",
          "conditions": [{
            "type": "httpHeader",
            "all": {
              "operand": "{{ if hasPrefix "*" $parts._0 }}ends-with{{ else }}equals{{end}}",
              "values": ["{{ trimPrefix "*" $parts._0 }}"],
              "caseSensitive": false
            },
            "name":"host"
          }{{ if $parts._1 }},
          {{ $myuri := rest $partslist | join "/" }}
          {
            "type": "httpUri",
            "path": {
              "operand": "starts-with",
              "values": ["/{{ $myuri }}"]
            }
          }{{- end}}],
          "actions": [{
            "type": "httpRedirect",
            "event": "request",            
            "location": {{ if eq $val  "https" }}"tcl:https://[getfield [HTTP::host] \":\" 1][HTTP::uri]"
            {{- else }}
            {{- if hasSuffix "$" $val }}
            {{- trimSuffix "$" $val | quote}}
            {{- else }}
            {{- if not $parts._1 }}
              "tcl:{{- $val }}[HTTP::uri]"
            {{- else }}
              {{ $myuri := rest $partslist | join "/" }}
              "tcl:{{- $val }}[string range [HTTP::uri] {{ len $myuri | add1}} end]"
            {{- end }}
            {{- end }}
            {{- end }}
          }]
        }
           {{- end }}
           {{- end }}
         ]
             }
{{- end }}
