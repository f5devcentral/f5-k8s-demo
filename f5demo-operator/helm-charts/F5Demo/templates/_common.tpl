{{/* Shared Objects */}}
{{- define "f5demo.common.empty.v1" }}
{{- end }}
{{- define "f5demo.common.basic.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
               }
       }
       },
{{- end }}
{{- define "f5demo.common.enhanced.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
            "XFF_HTTP_Profile": {
              "class": "HTTP_Profile",
                "xForwardedFor": true
               },
            "TCP_Profile": {
              "class": "TCP_Profile",
            "idleTimeout": 60
            },
            "Proxy_Protocol_iRule": {
              "class": "iRule",
              "iRule": {"base64":"I1BST1hZIFByb3RvY29sIFJlY2VpdmVyIGlSdWxlCiMgYy5qZW5pc29uIGF0IGY1LmNvbSAoQ2hhZCBKZW5pc29uKQojIHYyLjAgLSBBZGRlZCBzdXBwb3J0IGZvciBQUk9YWSBQcm90b2NvbCB2MiwgY29udHJvbCBmb3IgdjEsdjIgb3IgbGFjayBvZiBwcm94eSB2aWEgc3RhdGljOjogdmFyaWFibGVzIHNldCBpbiBSVUxFX0lOSVQKd2hlbiBSVUxFX0lOSVQgewogICAgc2V0IHN0YXRpYzo6YWxsb3dQcm94eVYxIDEKICAgIHNldCBzdGF0aWM6OmFsbG93UHJveHlWMiAxCiAgICBzZXQgc3RhdGljOjphbGxvd05vUHJveHkgMAp9CiAKd2hlbiBDTElFTlRfQUNDRVBURUQgewogICAgVENQOjpjb2xsZWN0Cn0KIAp3aGVuIENMSUVOVF9EQVRBIHsKICAgIGJpbmFyeSBzY2FuIFtUQ1A6OnBheWxvYWQgMTJdIEgqIHYyX3Byb3RvY29sX3NpZwogICAgaWYgeyRzdGF0aWM6OmFsbG93UHJveHlWMSAmJiBbVENQOjpwYXlsb2FkIDAgNV0gZXEgIlBST1hZIn0gewogICAgICAgIHNldCBwcm94eV9zdHJpbmcgW1RDUDo6cGF5bG9hZF0KICAgICAgICBzZXQgcHJveHlfc3RyaW5nX2xlbmd0aCBbZXhwciB7W3N0cmluZyBmaXJzdCAiXHIiIFtUQ1A6OnBheWxvYWRdXSArIDJ9XQogICAgICAgIHNjYW4gJHByb3h5X3N0cmluZyB7UFJPWFkgVENQJXMlcyVzJXMlc30gdGNwdmVyIHNyY2FkZHIgZHN0YWRkciBzcmNwb3J0IGRzdHBvcnQKICAgICAgICBsb2cgIlByb3h5IFByb3RvY29sIHYxIGNvbm4gZnJvbSBbSVA6OmNsaWVudF9hZGRyXTpbVENQOjpjbGllbnRfcG9ydF0gZm9yIGFuIElQdiR0Y3B2ZXIgc3RyZWFtIGZyb20gU3JjOiAkc3JjYWRkcjokc3JjcG9ydCB0byBEc3Q6ICRkc3RhZGRyOiRkc3Rwb3J0IgogICAgICAgIFRDUDo6cGF5bG9hZCByZXBsYWNlIDAgJHByb3h5X3N0cmluZ19sZW5ndGggIiIKICAgIH0gZWxzZWlmIHskc3RhdGljOjphbGxvd1Byb3h5VjIgJiYgJHYyX3Byb3RvY29sX3NpZyBlcSAiMGQwYTBkMGEwMDBkMGE1MTU1NDk1NDBhIn17CiAgICAgICAgYmluYXJ5IHNjYW4gW1RDUDo6cGF5bG9hZF0gQDEySCogdjJfcHJveHloZWFkZXJyZW1haW5kZXIKICAgICAgICBiaW5hcnkgc2NhbiBbVENQOjpwYXlsb2FkXSBAMTJIMkgqIHYyX3ZlckNvbW1hbmQgdjJfcmVtYWluZGVyCiAgICAgICAgaWYgeyR2Ml92ZXJDb21tYW5kID09IDIxfXsKICAgICAgICAgICAgYmluYXJ5IHNjYW4gW1RDUDo6cGF5bG9hZF0gQDEzSDIgdjJfYWRkcmVzc0ZhbWlseVRyYW5zcG9ydFByb3RvY29sCiAgICAgICAgICAgIGlmIHskdjJfYWRkcmVzc0ZhbWlseVRyYW5zcG9ydFByb3RvY29sID09IDExfSB7CiAgICAgICAgICAgICAgICBiaW5hcnkgc2NhbiBbVENQOjpwYXlsb2FkXSBAMTZjY2NjY2NjY1NTIHYyX3NvdXJjZUFkZHJlc3MxIHYyX3NvdXJjZUFkZHJlc3MyIHYyX3NvdXJjZUFkZHJlc3MzIHYyX3NvdXJjZUFkZHJlc3M0IHYyX2Rlc3RBZGRyZXNzMSB2Ml9kZXN0QWRkcmVzczIgdjJfZGVzdEFkZHJlc3MzIHYyX2Rlc3RBZGRyZXNzNCB2Ml9zb3VyY2VQb3J0MSB2Ml9kZXN0UG9ydDEKICAgICAgICAgICAgICAgIHNldCB2Ml9zb3VyY2VBZGRyZXNzICJbZXhwciB7JHYyX3NvdXJjZUFkZHJlc3MxICYgMHhmZn1dLltleHByIHskdjJfc291cmNlQWRkcmVzczIgJiAweGZmfV0uW2V4cHIgeyR2Ml9zb3VyY2VBZGRyZXNzMyAmIDB4ZmZ9XS5bZXhwciB7JHYyX3NvdXJjZUFkZHJlc3M0ICYgMHhmZn1dIgogICAgICAgICAgICAgICAgc2V0IHYyX2Rlc3RBZGRyZXNzICJbZXhwciB7JHYyX2Rlc3RBZGRyZXNzMSAmIDB4ZmZ9XS5bZXhwciB7JHYyX2Rlc3RBZGRyZXNzMiAmIDB4ZmZ9XS5bZXhwciB7JHYyX2Rlc3RBZGRyZXNzMyAmIDB4ZmZ9XS5bZXhwciB7JHYyX2Rlc3RBZGRyZXNzNCAmIDB4ZmZ9XSIKICAgICAgICAgICAgICAgIHNldCB2Ml9zb3VyY2VQb3J0IFtleHByIHskdjJfc291cmNlUG9ydDEgJiAweGZmZmZ9XQogICAgICAgICAgICAgICAgc2V0IHYyX2Rlc3RQb3J0IFtleHByIHskdjJfZGVzdFBvcnQxICYgMHhmZmZmfV0KICAgICAgICAgICAgICAgIGxvZyAiUHJveHkgUHJvdG9jb2wgdjIgY29ubiBmcm9tIFtJUDo6Y2xpZW50X2FkZHJdOltUQ1A6OmNsaWVudF9wb3J0XSBmb3IgYW4gSVB2NCBTdHJlYW0gZnJvbSBTcmM6ICR2Ml9zb3VyY2VBZGRyZXNzOiR2Ml9zb3VyY2VQb3J0IHRvIERzdDogJHYyX2Rlc3RBZGRyZXNzOiR2Ml9kZXN0UG9ydCIKICAgICAgICAgICAgICAgIFRDUDo6cGF5bG9hZCByZXBsYWNlIDAgMjggIiIKICAgICAgICAgICAgfSBlbHNlaWYgeyR2Ml9hZGRyZXNzRmFtaWx5VHJhbnNwb3J0UHJvdG9jb2wgPT0gMjF9IHsKICAgICAgICAgICAgICAgIGJpbmFyeSBzY2FuIFtUQ1A6OnBheWxvYWRdIEAxNkg0SDRINEg0SDRINEg0SCB2Ml92NnNvdXJjZUFkZHJlc3MxIHYyX3Y2c291cmNlQWRkcmVzczIgdjJfdjZzb3VyY2VBZGRyZXNzMyB2Ml92NnNvdXJjZUFkZHJlc3M0IHYyX3Y2c291cmNlQWRkcmVzczUgdjJfdjZzb3VyY2VBZGRyZXNzNiB2Ml92NnNvdXJjZUFkZHJlc3M3IHYyX3Y2c291cmNlQWRkcmVzczgKICAgICAgICAgICAgICAgIGJpbmFyeSBzY2FuIFtUQ1A6OnBheWxvYWRdIEAzMkg0SDRINEg0SDRINEg0SCB2Ml92NmRlc3RBZGRyZXNzMSB2Ml92NmRlc3RBZGRyZXNzMiB2Ml92NmRlc3RBZGRyZXNzMyB2Ml92NmRlc3RBZGRyZXNzNCB2Ml92NmRlc3RBZGRyZXNzNSB2Ml92NmRlc3RBZGRyZXNzNiB2Ml92NmRlc3RBZGRyZXNzNyB2Ml92NmRlc3RBZGRyZXNzOAogICAgICAgICAgICAgICAgYmluYXJ5IHNjYW4gW1RDUDo6cGF5bG9hZF0gQDQ4U1MgdjJfdjZzb3VyY2VQb3J0MSB2Ml92NmRlc3RQb3J0MQogICAgICAgICAgICAgICAgc2V0IHYyX3Y2c291cmNlUG9ydCBbZXhwciB7JHYyX3Y2c291cmNlUG9ydDEgJiAweGZmZmZ9XQogICAgICAgICAgICAgICAgc2V0IHYyX3Y2ZGVzdFBvcnQgW2V4cHIgeyR2Ml92NmRlc3RQb3J0MSAmIDB4ZmZmZn1dCiAgICAgICAgICAgICAgICBzZXQgdjJfdjZzb3VyY2VBZGRyZXNzICIkdjJfdjZzb3VyY2VBZGRyZXNzMTokdjJfdjZzb3VyY2VBZGRyZXNzMjokdjJfdjZzb3VyY2VBZGRyZXNzMzokdjJfdjZzb3VyY2VBZGRyZXNzNDokdjJfdjZzb3VyY2VBZGRyZXNzNTokdjJfdjZzb3VyY2VBZGRyZXNzNjokdjJfdjZzb3VyY2VBZGRyZXNzNzokdjJfdjZzb3VyY2VBZGRyZXNzOCIKICAgICAgICAgICAgICAgIHNldCB2Ml92NmRlc3RBZGRyZXNzICIkdjJfdjZkZXN0QWRkcmVzczE6JHYyX3Y2ZGVzdEFkZHJlc3MyOiR2Ml92NmRlc3RBZGRyZXNzMzokdjJfdjZkZXN0QWRkcmVzczQ6JHYyX3Y2ZGVzdEFkZHJlc3M1OiR2Ml92NmRlc3RBZGRyZXNzNjokdjJfdjZkZXN0QWRkcmVzczc6JHYyX3Y2ZGVzdEFkZHJlc3M4IgogICAgICAgICAgICAgICAgbG9nICJQcm94eSBQcm90b2NvbCB2MiBjb25uIGZyb20gZnJvbSBbSVA6OmNsaWVudF9hZGRyXTpbVENQOjpjbGllbnRfcG9ydF0gZm9yIGFuIElQdjYgU3RyZWFtIGZyb20gU3JjOiAkdjJfdjZzb3VyY2VBZGRyZXNzOiR2Ml92NnNvdXJjZVBvcnQgdG8gRHN0OiAkdjJfdjZkZXN0QWRkcmVzczokdjJfdjZkZXN0UG9ydCIKICAgICAgICAgICAgICAgIFRDUDo6cGF5bG9hZCByZXBsYWNlIDAgNTIgIiIKICAgICAgICAgICAgfSBlbHNlIHsKICAgICAgICAgICAgICAgIGxvZyAidjJfcHJveHkgY29ubiBmcm9tIFtJUDo6Y2xpZW50X2FkZHJdOltUQ1A6OmNsaWVudF9wb3J0XSAtIHBvc3NpYmxlIHVua25vd24vbWFsZm9ybWVkIHRyYW5zcG9ydFByb3RvY29sIG9yIGFkZHJlc3NGYW1pbHkiCiAgICAgICAgICAgICAgICByZWplY3QKICAgICAgICAgICAgfQogICAgICAgIH0gZWxzZWlmIHskdjJfdmVyQ29tbWFuZCA9PSAyMH17CiAgICAgICAgICAgIGxvZyAiUHJveHkgUHJvdG9jb2wgdjIgYW5kIExPQ0FMIGNvbW1hbmQgZnJvbSBbSVA6OmNsaWVudF9hZGRyXTpbVENQOjpjbGllbnRfcG9ydF07IGN1cnJlbnRseSB1bmhhbmRsZWQ7IGNvbm5lY3Rpb24gcmVzZXQiCiAgICAgICAgICAgIHJlamVjdAogICAgICAgIH0gZWxzZSB7CiAgICAgICAgICAgIGxvZyAiUHJveHkgUHJvdG9jb2wgUHJvdG9jb2wgU2lnbmF0dXJlIERldGVjdGVkIGZyb20gW0lQOjpjbGllbnRfYWRkcl06W1RDUDo6Y2xpZW50X3BvcnRdIGJ1dCBwcm90b2NvbCB2ZXJzaW9uIGFuZCBjb21tYW5kIG5vdCBsZWdhbDsgY29ubmVjdGlvbiByZXNldCIKICAgICAgICAgICAgcmVqZWN0CiAgICAgICAgfQogICAgfSBlbHNlaWYgeyRzdGF0aWM6OmFsbG93Tm9Qcm94eX0gewogICAgICAgIGxvZyAiQ29ubmVjdGlvbiBmcm9tIFtJUDo6Y2xpZW50X2FkZHJdOltUQ1A6OmNsaWVudF9wb3J0XSBhbGxvd2VkIGRlc3BpdGUgbGFjayBvZiBQUk9YWSBwcm90b2NvbCBoZWFkZXIiCiAgICB9IGVsc2UgewogICAgICAgIHJlamVjdAogICAgICAgIGxvZyAiQ29ubmVjdGlvbiByZWplY3RlZCBmcm9tIFtJUDo6Y2xpZW50X2FkZHJdOltUQ1A6OmNsaWVudF9wb3J0XSBkdWUgdG8gbGFjayBvZiBQUk9YWSBwcm90b2NvbCBoZWFkZXIiCiAgICB9CiAgICBUQ1A6OnJlbGVhc2UKfQo="}}
       }
       },
{{- end }}
{{- define "f5demo.common.dns.v1" }}
       "Common": {
          "class": "Tenant",
          "Shared": {
            "class": "Application",
            "template": "shared",
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
