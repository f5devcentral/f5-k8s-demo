{{/* Basic TCP */}}
{{- define "f5demo.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{- else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}],
               "remark":"{{ .name}}: f5demo.tcp.v1",
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
                "pool": "{{- .name}}_pool"
             },
             "{{- .name }}_pool": {
                "class": "Pool",
                "monitors": [ "tcp" ],
                "members": [{
                   "servicePort": 80,
                   "serverAddresses": []
                }]
             }
{{- end }}
{{- define "f5demo.proxyprotocol.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.proxyprotocol.tcp.v1",
               "pool": "{{- .name}}_pool",
               "iRules": ["/Common/Shared/Proxy_Protocol_Send"]
             },
             "{{- .name }}_pool": {
                "class": "Pool",
                "monitors": [
                   "tcp"
                ],
                "members": [{
                   "servicePort": 80,
                   "serverAddresses": []
                }]
             }
{{- end }}
{{- define "f5demo.snirouter.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               "remark":"{{ .name}}: f5demo.snirouter.tcp.v1",
               {{ if not .virtualPort }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "persistenceMethods": ["tls-session-id"],
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
          "name": "forward_to_{{ $local.cnt }}",
          "conditions": [{
            "type": "sslExtension",
            "serverName": {
              "operand": "{{ if hasPrefix "*" $key }}ends-with{{ else }}equals{{end}}",
              "values": ["{{ trimPrefix "*" $key }}"]
            }
          }
           ],
          "actions": [
            {
            "type": "forward",
            "event": "ssl-client-hello",
            "select": {
              "service": {"use":"{{ $val }}"}
            }
          }]
        }
           {{- end }}
           {{- end }}
         ]
             }
{{- end }}
