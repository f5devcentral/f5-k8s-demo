stage('clone git repo') {
   node {
     git url: 'https://github.com/f5devcentral/f5-k8s-demo.git', branch:'1.1.0'
   }
}
stage('delete DNS') {
    node {
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~my-frontend.f5demo.com'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~www.f5demo.com'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/wideip/a/~Common~app1.f5demo.com'

        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~my-frontend_pool'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~my-website_pool'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/pool/a/~Common~app1_pool'

        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-frontend_vs'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/my-website_vs'
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/gtm/server/~Common~bigip/virtual-servers/app1_vs'
    }
    
}
stage('delete website') {
    node {
        sh 'kubectl delete -f my-website-configmap.yaml'
        sh 'kubectl delete -f my-website-service.yaml'
        sh 'kubectl delete -f my-website-deployment.yaml'
    }
}
stage ('deploy app1') {
    node {
        sh 'kubectl delete -f app1-configmap-bad.yaml'  
        sh 'kubectl delete -f app1-service.yaml'
        sh 'kubectl delete -f app1-deployment.yaml'
    }
}
stage ('delete content routing / DNS') {
 node {
    sh 'python custom_automation.py  --host 10.1.10.60'   
 }   
}

