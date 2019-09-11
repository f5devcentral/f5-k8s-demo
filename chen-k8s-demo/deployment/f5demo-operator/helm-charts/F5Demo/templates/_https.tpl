{{/* Basic HTTPS */}}
{{- define "f5demo.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{- if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.https.v1",
               "pool": "{{ .pool | default "{{ .name }}_pool"}}",	       
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "redirect80": {{ .redirect80 | default false }},            
               "serverTLS": {{ .serverTLS | default "{\"bigip\":\"/Common/clientssl\"}"}},
               "clientTLS": {{ .clientTLS | default "{\"bigip\":\"/Common/serverssl\"}"}}
             }{{if not .pool }},
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
             }{{- end }}
{{- end }}
{{- define "f5demo.sni.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{- if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.sni.https.v1",
               "pool": "{{ .pool | default "{{ .name }}_pool"}}",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "redirect80": {{ .redirect80 | default false }},            
               "serverTLS": {{ .serverTLS | default "{\"bigip\":\"/Common/clientssl\"}"}},
               "clientTLS": {{ .clientTLS | default "{\"bigip\":\"/Common/serverssl\"}"}},	       
               "iRules": ["/Common/Shared/Host_Header_To_Sni"]
             }{{if not .pool }},
             "{{ .pool | default "{{ .name }}_pool"}}: {
                "class": "Pool",
                "monitors": [
                   "https"
                ],
                "members": [{
                   "servicePort": 443,
                   "serverAddresses": [
                   ]
                }]
             }{{- end }}
{{- end }}
{{- define "f5demo.identity.sni.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{- if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.identity.sni.https.v1",
               "pool": "{{ .pool | default "{{ .name }}_pool"}}",
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "redirect80": {{ .redirect80 | default false }},            
               "serverTLS": {{ .serverTLS | default "{\"bigip\":\"/Common/clientssl\"}"}},
               "clientTLS": {{ .clientTLS | default "{\"bigip\":\"/Common/serverssl\"}"}},	       
               "iRules": ["/Common/Shared/Host_Header_To_Sni"],
               "policyIAM": {
                 "bigip": "{{ .identityPolicy }}"
               }
             }{{if not .pool }},
             "{{ .pool | default "{{ .name }}_pool"}}: {
                "class": "Pool",
                "monitors": [
                   "https"
                ],
                "members": [{
                   "servicePort": 443,
                   "serverAddresses": [
                   ]
                }]
             }{{- end }}
{{- end }}
{{- define "f5demo.waf.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.waf.https.v1",
               "pool": "{{ .name }}_pool",
               "redirect80": {{ .redirect80 | default false }},
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "serverTLS": {{ .serverTLS | default "{\"bigip\":\"/Common/clientssl\"}"}},
               "clientTLS": {{ .clientTLS | default "{\"bigip\":\"/Common/serverssl\"}"}},
               "policyWAF": {{ .policyWAF | default "{\"bigip\":\"/Common/linux-low\"}"}},
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
{{- define "f5demo.waf.sni.https.v1" }}
             "{{ .name }}": {
                "class": "Service_HTTPS",
                "virtualAddresses": [
                   {{- if .virtualAddress }}{{ .virtualAddress | quote }}{{ else }}
                     {"use":"/Common/Shared/VIP_TARGET"}
                   {{- end }}
                ],
               {{ if not .virtualAddress }}"virtualPort": {{ .cnt }},{{ else }}
               {{ if .virtualPort }}"virtualPort": {{ .virtualPort }},{{- end }}{{- end}}
               "remark":"{{ .name}}: f5demo.waf.sni.https.v1",
               "pool": "{{ .pool | default "{{ .name }}_pool"}}",	       
               "redirect80": {{ .redirect80 | default false }},
               "profileHTTP":{"use": "/Common/Shared/XFF_HTTP_Profile"},
               "serverTLS": {{ .serverTLS | default "{\"bigip\":\"/Common/clientssl\"}"}},
               "clientTLS": {{ .clientTLS | default "{\"bigip\":\"/Common/serverssl\"}"}},
               "policyWAF": {{ .policyWAF | default "{\"bigip\":\"/Common/linux-low\"}"}},
               "iRules": ["/Common/Shared/Host_Header_To_Sni"],	       
               "securityLogProfiles": [
                 {
                   "bigip": "/Common/Log all requests"
                 }                  
               ]
             }{{if not .pool }},
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
             }{{- end }}
{{- end }}