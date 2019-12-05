
// API endpoints
var nginxApiBaseUri = "/api/5";
var nginxMetaApi = `${nginxApiBaseUri}/nginx`;
var nginxApiPoolsUri = `${nginxApiBaseUri}/http/keyvals/pools`;
var nginxApiUpstreamsUri = `${nginxApiBaseUri}/http/upstreams`;
var as3DeclarationUri = "/mgmt/shared/appsvcs/declare";
var f5CloudSvcsDnsBaseUri = "/v1/svc-subscription/subscriptions";

var demoDomain = ".f5demo.com";
var fqdnRegexString = `([a-zA-Z0-9])+${demoDomain.replace(".", ".\\")}`;
var dataCenters = { "10.1.20.54": "dc1", "10.1.20.55": "dc2" };
var publicIps = { "10.1.20.54": "192.0.2.10", "10.1.20.55": "192.0.2.11" };

function StatusByFqdn(r) {
    r.subrequest(`${nginxApiBaseUri}/http/upstreams`, {
        method: "GET"
    }, (res) => {
        var myRe = RegExp(fqdnRegexString);
        var needle = r.args["fqdn"];

        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);
            for (var u in input) {
                var match = myRe.exec(u);
                if (match && match[0] === needle) {
                    var cnt = input[u]["peers"].filter(filterUp).length;
                    if (cnt) {
                        r.return(res.status, JSON.stringify({ "status": true }));
                        return;
                    } else {
                        r.return(res.status, JSON.stringify({ "status": false }));
                        return;
                    }
                }
            }
            r.return(res.status, JSON.stringify({ "status": false }));
            return;
        }
        r.return(500);
    });
}

function UpdatePools(r) {
    r.subrequest(nginxApiUpstreamsUri, {
        method: "GET"
    }, (res) => {
        var output = {};

        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);

            for (var u in input) {
                if (!isLocalHost(u)) {
                    output[u] = input[u].peers.filter(filterUp).length;
                }
            }
            r.variables.pool = JSON.stringify(output);
            r.return(res.status, JSON.stringify(output));
            return;
        }
        r.return(500);
    });
}

function Summarize(r) {
    r.subrequest(nginxApiPoolsUri, {
        method: "GET"
    }, (res) => {
        var output = {};

        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);
            for (var u in input) {
                var dataCenter = dataCenters[u];
                var entry = JSON.parse(input[u]);
                for (var app in entry) {
                    var poolName = dataCenter;
                    if (app + demoDomain in output) {
                        output[app + demoDomain];
                    } else {
                        output[app + demoDomain] = {};
                    }
                    if (poolName in output[app + demoDomain]) {
                        output[app + demoDomain][poolName].push({ [u]: entry[app] });
                    } else {
                        output[app + demoDomain][poolName] = [{ [u]: entry[app] }];
                    }
                }

            }
            r.return(res.status, JSON.stringify(output));
            return;
        }
    });
}


function GenerateAS3(r) {
    var poolSuffix = "_pool";
    r.subrequest(nginxApiPoolsUri, {
        method: "GET"
    }, (res) => {
        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);
            var myRe = RegExp(fqdnRegexString);
            var template = {
                "class": "ADC",
                "schemaVersion": "3.7.0",
                "id": "NGINXPLUS",
                "NGINXPlus": {
                    "class": "Tenant",
                    "Apps": {
                        "class": "Application",
                        "template": "http",
                        "serviceMain": {
                            "class": "Service_HTTP",
                            "virtualPort": 8080,
                            "virtualAddresses": [
                                "10.0.0.200"
                            ],
                            "persistenceMethods": [],
                            "profileMultiplex": {
                                "bigip": "/Common/oneconnect"
                            }
                        }
                    }
                }
            };

            for (var u in input) {
                if (!isLocalHost(u)) {
                    var entry = JSON.parse(input[u]);
                    for (var app in entry) {
                        var match = myRe.exec(app);
                        if (match) {
                            app = match[1];
                        }
                        if (app + poolSuffix in template.NGINXPlus.Apps) {
                            template.NGINXPlus.Apps[app + poolSuffix].members.push({
                                "servicePort": 80,
                                "serverAddresses": [u]
                            });
                        } else {
                            template.NGINXPlus.Apps[app + poolSuffix] = {
                                "class": "Pool",
                                "members": [{
                                    "servicePort": 80,
                                    "serverAddresses": [u]
                                }]
                            };
                        }
                    }
                }
            }
            r.subrequest(as3DeclarationUri, {
                method: "POST",
                body: JSON.stringify(template)
            }, (res) => {
                if (isResultStatusGood(res)) {
                    var input = JSON.parse(res.responseBody);
                    r.return(res.status, JSON.stringify(input));
                    return;
                }
                r.return(res.status, res.responseBody);
            });
        }
        r.return(500);
    });
}

function Version(r) {
    r.subrequest(nginxMetaApi, {
        method: "GET"
    }, (res) => {
        if (!isResultStatusGood(res)) {
            r.return(res.status);
            return;
        }

        var json = JSON.parse(res.responseBody);
        r.return(200, json.version);
    });
}

function GenerateAS3Dns(r) {
    r.subrequest(nginxApiPoolsUri, {
        method: "GET"
    }, (res) => {
        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);
            var myRe = RegExp(fqdnRegexString);
            var template = {
                "class": "ADC",
                "schemaVersion": "3.7.0",
                "id": "NGINXPLUS",
                "Common": {
                    "class": "Tenant",
                    "Shared": {
                        "class": "Application",
                        "template": "shared",
                        "myMonitor": {
                            "class": "GSLB_Monitor",
                            "monitorType": "tcp",
                            "send": ""
                        },
                        "AS3DataCenter": {
                            "class": "GSLB_Data_Center"
                        },
                        "AS3Server": {
                            "class": "GSLB_Server",
                            "dataCenter": {
                                "use": "AS3DataCenter"
                            },
                            "devices": [{
                                "address": "10.1.10.241",
                                "addressTranslation": "10.1.10.241"
                            }],
                            "virtualServers": []
                        }
                    }
                },
                "NGINXPlusDNS": {
                    "class": "Tenant",
                    "DNS": {
                        "class": "Application",
                        "template": "generic"
                    }
                }
            };

            var virtualServers = {};

            var x = 0;
            for (var u in input) {

                virtualServers[u] = x.toString();
                var dataCenter = dataCenters[u];
                x++;
                template.Common.Shared.AS3Server.virtualServers.push({
                    "address": u,
                    "addressTranslation": u,
                    "addressTranslationPort": 443,
                    "port": 443,
                    "monitors": [{ "use": "myMonitor" }]
                });
                if (!isLocalHost(u)) {
                    var entry = JSON.parse(input[u]);
                    for (var app in entry) {
                        var cnt = entry[app];
                        var tmp = myRe.exec(app);
                        if (tmp) {
                            app = tmp[1];
                        }
                        var member = {
                            "server": {
                                "use": "/Common/Shared/AS3Server"
                            },
                            "virtualServer": virtualServers[u]
                        };

                        var poolName = `${dataCenter}_${app}_pool`;
                        if (poolName in template.NGINXPlusDNS.DNS) {
                            template.NGINXPlusDNS.DNS[poolName].members.push(member);
                        } else {
                            template.NGINXPlusDNS.DNS[poolName] = {
                                "class": "GSLB_Pool",
                                "members": [member],
                                "resourceRecordType": "A"
                            };
                            if (cnt == 0) {
                                template.NGINXPlusDNS.DNS[poolName].enabled = false;
                            }
                        }
                        if (app + "_domain" in template.NGINXPlusDNS.DNS) {
                            template.NGINXPlusDNS.DNS[app + "_domain"].pools.push({
                                "use": poolName
                            });
                        } else {
                            template.NGINXPlusDNS.DNS[app + "_domain"] = {
                                "class": "GSLB_Domain",
                                "domainName": app + demoDomain,
                                "resourceRecordType": "A",
                                "pools": [{
                                    "use": poolName
                                }]
                            };
                        }
                    }
                }
            }
            r.subrequest(as3DeclarationUri, {
                method: "POST",
                body: JSON.stringify(template)
            }, (res) => {
                if (isResultStatusGood(res)) {
                    var input = JSON.parse(res.responseBody);
                    r.return(res.status, JSON.stringify(input));
                    return;
                }
                r.return(res.status, res.responseBody);
            });

        }
        r.return(500);
    });
}


function GenerateCloudDns(r) {
    r.subrequest(nginxApiPoolsUri, {
        method: "GET"
    }, (res) => {
        if (isResultStatusGood(res)) {
            var input = JSON.parse(res.responseBody);
            var template = {
                "account_id": "{{ACCOUNT_ID}}",
                "catalog_id": "c-aaQnOrPjGu",
                "plan_id": "p-__free_dns",
                "service_type": "gslb",
                "service_instance_name": "{{SERVICE_INSTANCE_NAME}}",
                "configuration": {
                    "gslb_service": {
                        "load_balanced_records": {
                        },
                        "pools": {
                        },
                        "virtual_servers": {
                        },
                        "zone": "{{GSLB_ZONE}}"
                    },
                    "schemaVersion": "0.1"
                }

            };
            if ("account_id" in r.args) {
                template["account_id"] = r.args["account_id"];
            }
            if ("gslb_zone" in r.args) {
                template.configuration.gslb_service.zone = r.args["gslb_zone"];
                template["service_instance_name"] = r.args["gslb_zone"];
            }

            var virtualServers = {};

            var x = 0;
            for (var u in input) {

                virtualServers[u] = x;

                var dataCenter = dataCenters[u];
                x++;

                if (!isLocalHost(u)) {
                    var entry = JSON.parse(input[u]);
                    for (var app in entry) {
                        var cnt = entry[app];
                        if (cnt == 0) {
                            continue;
                        }
                        var poolName = `pools_${dataCenter}_${app}`;
                        var ipEndpoint = `ipEndpoints_${dataCenter}_${app}_instance_`;
                        if (!(app in template.configuration.gslb_service.load_balanced_records)) {
                            template.configuration.gslb_service.load_balanced_records[app] = {
                                "aliases": [
                                    app
                                ],
                                "display_name": app,
                                "enable": true,
                                "persist_cidr_ipv4": 24,
                                "persist_cidr_ipv6": 56,
                                "persistence": true,
                                "persistence_ttl": 3600,
                                "proximity_rules": [
                                    {
                                        "region": "global",
                                        "pool": poolName,
                                        "score": 100
                                    }
                                ],
                                "rr_type": "A"
                            }
                        } else {
                            template.configuration.gslb_service.load_balanced_records[app].proximity_rules.push({
                                "region": "global",
                                "pool": poolName,
                                "score": 100
                            });
                        }
                        if (!(poolName in template.configuration.gslb_service.pools)) {
                            template.configuration.gslb_service.pools[poolName] = {
                                "display_name": `${dataCenter}_${app}`,
                                "enable": true,
                                "load_balancing_mode": "round-robin",
                                "max_answers": 1,
                                "members": [
                                    {
                                        "virtual_server": ipEndpoint + virtualServers[u]
                                    }
                                ],
                                "rr_type": "A",
                                "ttl": 30
                            }

                        } else {
                            template.configuration.gslb_service.pools[poolName].members.push({ "virtual_server": ipEndpoint + virtualServers[u] });
                        }
                        template.configuration.gslb_service.virtual_servers[ipEndpoint + virtualServers[u]] = {
                            "display_name": "dc1_app001_instance_1",
                            "address": publicIps[u],
                            "port": 80
                        }
                    }
                }
            }
            r.subrequest(`${f5CloudSvcsDnsBaseUri}/${r.args["subscription_id"]}`, {
                method: "PUT",
                body: JSON.stringify(template)
            }, (res) => {
                if (isResultStatusGood(res)) {
                    var input = JSON.parse(res.responseBody);
                    r.return(res.status, JSON.stringify(input));
                    return;
                }
                r.return(res.status, res.responseBody);
            });
        }
        r.return(500);
    });
}

// utility functions

function isResultStatusGood(res) {
    return res.status == 200;
}

function isLocalHost(host) {
    return host === "127.0.0.1";
}

function filterUp(item) {
    if (item.state.toLowerCase() === "up") {
        return true;
    }
    return false;
}
