stage('clone git repo') {
   node {
     git url: 'https://github.com/f5devcentral/f5-k8s-demo.git', branch:'1.3.0'
   }
}

stage('Delete BACKEND') {
    node {
        sh 'kubectl delete -f my-backend-service.yaml'
        sh 'kubectl delete -f my-backend-deployment.yaml'
    }
}

stage('Delete FRONTEND App') {
    node {
        sh 'kubectl delete -f my-frontend-configmap.yaml'
        sh 'kubectl delete -f my-frontend-service.yaml'
        sh 'kubectl delete -f my-frontend-deployment.yaml'
        }
}
stage('Delete Ingress') {
    node {
        sh 'kubectl delete -f blue-green-ingress.yaml'
        sh 'kubectl delete -f node-blue.yaml'
        sh 'kubectl delete -f node-green.yaml'
        }
}

stage('Delete F5 Container Connector') {
    node {
        sh 'sleep 30'
        sh 'kubectl delete -f f5-cc-deployment.yaml'
        sh 'kubectl delete secret bigip-login -n kube-system'
    }
}

stage('delete kubernetes partition') {
    node {
        sh 'curl -k -u admin:admin -H "Content-Type: application/json" -X DELETE https://10.1.1.8/mgmt/tm/sys/folder/~kubernetes'
    }
}
