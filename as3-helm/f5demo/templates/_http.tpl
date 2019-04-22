{{/* Basic HTTP */}}
{{- define "f5demo.http.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTP",
                "virtualAddresses": [
                   {{ .virtualAddress | quote }}
                ],
               "virtualPort": {{ .virtualPort | default 80 }},
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
                   {{ .virtualAddress | quote }}
                ],
               "virtualPort": {{ .virtualPort | default 80 }},           
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