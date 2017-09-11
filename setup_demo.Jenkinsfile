stage('clone git repo') {
   node {
     git url: 'https://github.com/f5devcentral/f5-k8s-demo.git', branch:'1.1.1'
   }
}
stage('create kubernetes partition') {
    node {
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X POST -d \'{"name":"kubernetes", "fullPath": "/kubernetes", "subPath": "/"}\' https://10.1.1.8/mgmt/tm/sys/folder |python -m json.tool'
    }
}
stage('deploy F5 Container Connector') {
    node {
        sh 'kubectl create secret generic bigip-login --namespace kube-system --from-literal=username=admin --from-literal=password=admin'
        sh 'kubectl create -f f5-cc-deployment.yaml'
    }
}
stage('Deploy FRONTEND App') {
    node {
        sh 'kubectl create -f my-frontend-deployment.yaml'
        sh 'kubectl create -f my-frontend-configmap.yaml'
        sh 'kubectl create -f my-frontend-service.yaml'
    }
}
stage('Verify FRONTEND') {
    node {
        sh 'sleep 30'
        sh 'curl 10.1.10.81 | grep "Welcome to Demo App"'
    }    
}
stage('Deploy INGRESS') {
    node {
        sh 'kubectl create -f node-blue.yaml'
        sh 'kubectl create -f node-green.yaml'
        sh 'kubectl create -f blue-green-ingress.yaml'
    }
}
stage('Verify INGRESS') {
   node {
        sh 'sleep 30'
        sh 'curl -H host:blue.f5demo.com 10.1.10.82|grep Blue'
        sh 'curl -H host:green.f5demo.com 10.1.10.82|grep Green'
   }
}
stage('Deploy ASP') {
    node {
        sh 'kubectl create -f f5-asp-configmap.yaml'
        sh 'kubectl create -f f5-asp-daemonset.yaml'
    }
}
stage('Deploy F5 Kube Proxy') {
    node {
        sh 'kubectl delete -f kube-proxy-origin.yaml'
        sh 'kubectl create -f f5-kube-proxy-ds.yaml'
    }
}

stage('Deploy BACKEND') {
    node {
        sh 'kubectl create -f my-backend-deployment.yaml'
        sh 'kubectl create -f my-backend-service.yaml'
    }
}
stage('Verify BACKEND') {
    node {
        sh 'sleep 30'
        sh 'curl 10.1.10.81/backend/ |grep "Backend App"'
    }    
}

    
