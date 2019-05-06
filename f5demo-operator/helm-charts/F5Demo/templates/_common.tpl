{{/* Shared Objects */}}
{{- define "f5demo.common.empty.v1" }}
{{- end }}
{{- define "f5demo.common.basic.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            {{- if .Values.common.vipTarget }}
            "VIP_TARGET": {
              "class": "Service_Address",
              "virtualAddress": "{{ .Values.common.vipTarget }}"
            },
            {{- end }}
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
               }
                {{- $local := dict "first" true  }}       
                {{ range $key, $val := .Values.common.irules }},
                {{- if not $local.first }},{{- end }}
                {{- $_ := set $local "first" false  }}
                "{{ $key }}": {
                  "class":"iRule",
                  "iRule": {"base64": "{{ $.Files.Get $val | b64enc }}"}
                }
                {{ end }}

       }
       },
{{- end }}
{{- define "f5demo.common.enhanced.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            {{- if .Values.common.vipTarget }}
            "VIP_TARGET": {
              "class": "Service_Address",
              "virtualAddress": "{{ .Values.common.vipTarget }}"
            },
            {{- end }}
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
               },
            "TCP_Profile": {
              "class": "TCP_Profile",
            "idleTimeout": 60
            }
                {{- $local := dict "first" true  }}       
                {{ range $key, $val := .Values.common.irules }}
                {{- if not $local.first }},{{- end }}
                {{- $_ := set $local "first" false  }}
                "{{ $key }}": {
                  "class":"iRule",
                  "iRule": {"base64": "{{ $.Files.Get $val | b64enc }}"}
                }
                {{ end }}

       },
{{- end }}
{{- define "f5demo.common.dns.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            {{- if .Values.common.vipTarget }}
            "VIP_TARGET": {
              "class": "Service_Address",
              "virtualAddress": "{{ .Values.common.vipTarget }}"
            },
            {{- end }}
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
             },
                {{- $local := dict "first" true  }}       
                {{ range $key, $val := .Values.common.irules }}
                {{- if not $local.first }},{{- end }}
                {{- $_ := set $local "first" false  }}
                "{{ $key }}": {
                  "class":"iRule",
                  "iRule": {"base64": "{{ $.Files.Get $val | b64enc }}"}
                }
                {{ end }}
             ,"AS3Server": {
                                "class": "GSLB_Server",
                                "dataCenter": 
                                         {"bigip":"/Common/UDF"}
                                ,
                                "devices": [{
                                                "address": "{{ .Values.common.device0.address }}",
                                                "addressTranslation": "{{ .Values.common.device0.addressTranslation }}"
                                        }
                                ]
                                ,
                                "virtualServers": [
                                       {{- $local := dict "first" true "first2" true }}

                                       {{- range $vs := .Values.common.virtualServers }}
                                       {{- if not $local.first }},{{- end }}
                                       {{- $_ := set $local "first" false  }}
                                       { 
                                         {{- $_ := set $local "first2" true  }}
                                       {{- range $key, $val := $vs }} 
                                         {{- if not $local.first2 }},{{- end }}
                                         {{- $_ := set $local "first2" false  }}
				         {{- $lowerkey := $key | lower }}
                                           {{- if contains "port" $lowerkey }}
                                             {{ $key | quote }}: {{- $val -}}  
                                             {{ else }}
                                             {{ $key | quote }}: {{- $val | quote -}}
                                           {{ end }}
                                         {{- end }} 
                                       }
                                       {{- end -}}
                                ]
                        }
          }
       },
{{- end }}
{{- define "f5demo.common.dns.v2" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            {{- if .Values.common.vipTarget }}
            "VIP_TARGET": {
              "class": "Service_Address",
              "virtualAddress": "{{ .Values.common.vipTarget }}"
            },
            {{- end }}
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
             },
                {{- $local := dict "first" true  }}       
                {{ range $key, $val := .Values.common.irules }}
                {{- if not $local.first }},{{- end }}
                {{- $_ := set $local "first" false  }}
                "{{ $key }}": {
                  "class":"iRule",
                  "iRule": {"base64": "{{ $.Files.Get $val | b64enc }}"}
                }
                {{ end }}
          }
       },
{{- end }}
