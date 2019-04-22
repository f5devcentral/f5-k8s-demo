{{/* Basic TCP */}}
{{- define "f5demo.tcp.v1" }}
             "{{- .name }}": {
                "class": "Service_TCP",
                "virtualAddresses": [
                   "{{- .virtualAddress }}"
                ],
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