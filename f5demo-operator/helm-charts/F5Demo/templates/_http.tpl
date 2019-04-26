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
{{- define "f5demo.waf.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "pool": "{{ .name }}_pool",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "policyWAF":{"bigip":"/Common/linux-low"},
               "securityLogProfiles": [
               {
                 "bigip": "/Common/Log all requests"
               }
               ]
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
           {{- $local := dict "first" true  }}       
           {{- range .targets }}
           {{- range $key, $val :=. }}
           {{- if not $local.first }},{{- end }}
           {{- $_ := set $local "first" false  }}
           {
          "name": "forward_to_{{$val}}",
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
         ]
             }
{{- end }}
