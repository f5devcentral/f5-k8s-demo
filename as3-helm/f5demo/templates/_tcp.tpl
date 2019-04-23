{{/* Basic TCP */}}
{{- define "f5demo.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   "{{- .virtualAddress }}"
                ],
               "remark":"{{ .name}}: f5demo.tcp.v1",
               "virtualPort": {{- .virtualPort }},
                "pool": "{{- .name}}_pool"
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
{{- define "f5demo.proxyprotocol.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   "{{- .virtualAddress }}"
                ],
               "virtualPort": {{- .virtualPort }},
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
                   "{{- .virtualAddress }}"
                ],
               "remark":"{{ .name}}: f5demo.snirouter.tcp.v1",
               "virtualPort": {{- .virtualPort }},
               "persistenceMethods": ["tls-session-id"],
               "policyEndpoint": "{{- .name}}_policy_endpoint"
             },
             "{{- .name }}_policy_endpoint": {
                "class": "Endpoint_Policy",
        "rules": [
           {{- $local := dict "first" true  }}       
           {{- range .targets }}
           {{- range $key, $val :=. }}
           {{- if not $local.first }},{{- end }}
           {{- $_ := set $local "first" false  }}
           {
          "name": "forward_to_{{$val}}",
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
