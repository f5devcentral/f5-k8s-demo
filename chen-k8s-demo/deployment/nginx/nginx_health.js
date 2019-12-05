function StatusByFqdn(r) {
    r.subrequest("/api/5/http/upstreams", {
        method: "GET"
    }, (res) => {
        var myRe = /[a-zA-Z0-9]+\.f5demo\.com/;
        var needle = r.args["fqdn"];
        function filterUp(item) {
            if (item.state === "up") {
                return true;
            }
            return false;
        }

        if (res.status == 200) {
            var input = JSON.parse(res.responseBody);
            for (var u in input) {
                var tmp = myRe.exec(u);
                if (tmp && tmp[0] === needle) {
                    var cnt = input[u].peers.filter(filterUp).length;
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
