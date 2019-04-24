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