{{/* Basic DNS */}}
{{- define "f5demo.dns.v1" }}
            "{{ .name }}_pool": {
                "class": "GSLB_Pool",
                "members": [
                    {
                        "ratio": 10,
                        "server": {
                            "use": "/Common/Shared/AS3Server"
                        },
                        "virtualServer": "{{ .virtualServer }}"
                    }
                ],
                "resourceRecordType": "A"
            },
                        "{{ .name }}_Domain": {
                                "class": "GSLB_Domain",
                                "domainName": "{{ .fqdn }}",
                                "resourceRecordType": "A",
                                "pools": [{
                                                "use": "{{ .name }}_pool"
                                        }
                                ]
                        }
{{- end -}}
{{- define "f5demo.dns.v2" }}
            "{{ .name }}_pool": {
                "class": "GSLB_Pool",
                "members": [
                    {
                        "ratio": 10,
                        "server": {
                            "bigip": "{{ .server }}"
                        },
                        "virtualServer": "{{ .virtualServer }}"
                    }
                ],
                "resourceRecordType": "A"
            },
                        "{{ .name }}_Domain": {
                                "class": "GSLB_Domain",
                                "domainName": "{{ .fqdn }}",
                                "resourceRecordType": "A",
                                "pools": [{
                                                "use": "{{ .name }}_pool"
                                        }
                                ]
                        }
{{- end -}}

{{- define "f5demo.sni.dns.v1" }}
            "{{ .name }}_pool": {
                "class": "GSLB_Pool",
                "members": [
                    {
                        "ratio": 10,
                        "server": {
                            "use": "/Common/Shared/AS3Server"
                        },
                        "virtualServer": "{{ .virtualServer }}"
                    }
                ],
                "resourceRecordType": "A",
                "monitors": [{"use": "{{ .name}}_monitor"} ]
            },
            "{{ .name }}_monitor": {
               "class": "GSLB_Monitor",
               "monitorType":"http",
                "send":"{{ .send}} HTTP/1.1\r\nhost: {{ .fqdn }}\r\nconnection: close\r\n\r\n",
                "receive": {{ .receive | quote }}
               },
                        "{{ .name }}_Domain": {
                                "class": "GSLB_Domain",
                                "domainName": "{{ .fqdn }}",
                                "resourceRecordType": "A",
                                "pools": [{
                                                "use": "{{ .name }}_pool"
                                        }
                                ]
                        }
{{- end -}}

{{- define "f5demo.sni.dns.v2" }}
            "{{ .name }}_pool": {
                "class": "GSLB_Pool",
                "members": [
                    {
                        "ratio": 10,
                        "server": {
                            "bigip": "{{ .server }}"
                        },
                        "virtualServer": "{{ .virtualServer }}"
                    }
                ],
                "resourceRecordType": "A",
                "monitors": [{"use": "{{ .name}}_monitor"} ]
            },
            "{{ .name }}_monitor": {
               "class": "GSLB_Monitor",
               "monitorType":"http",
                "send":"{{ .send}} HTTP/1.1\r\nhost: {{ .fqdn }}\r\nconnection: close\r\n\r\n",
                "receive": {{ .receive | quote }}
               },
                        "{{ .name }}_Domain": {
                                "class": "GSLB_Domain",
                                "domainName": "{{ .fqdn }}",
                                "resourceRecordType": "A",
                                "pools": [{
                                                "use": "{{ .name }}_pool"
                                        }
                                ]
                        }
{{- end -}}