{{/* Basic HTTPS */}}
{{- define "f5demo.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{ .virtualAddress | quote }}
                ],
               "virtualPort": {{ .virtualPort | default 443 }},
                "pool": "{{ .name }}_pool",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "redirect80": {{ .redirect80 | default false }},            
               "serverTLS": {"bigip":"/Common/clientssl"},
               "clientTLS": {"bigip":"/Common/serverssl"}
             },
             "{{ .name }}_pool": {
                "class": "Pool",
                "monitors": [
                   "https"
                ],
                "members": [{
                   "servicePort": 443,
                   "serverAddresses": [
                   ]
                }]
             }
{{- end }}
{{- define "f5demo.waf.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{ .virtualAddress | quote }}
                ],
               "virtualPort": {{ .virtualPort | default 443 }},
               "pool": "{{ .name }}_pool",
               "redirect80": {{ .redirect80 | default false }},
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "serverTLS": {"bigip":"/Common/clientssl"},
               "clientTLS": {"bigip":"/Common/serverssl"},
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
                   "https"
                ],
                "members": [{
                   "servicePort": 443,
                   "serverAddresses": [
                   ]
                }]
             }
{{- end }}