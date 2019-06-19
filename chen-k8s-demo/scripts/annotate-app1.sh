replace="s/%IPADDR%/`kubectl get svc app1 -o json |jq ".spec.clusterIP" -r`/g"
sed -e $replace $1 | kubectl replace -f -
