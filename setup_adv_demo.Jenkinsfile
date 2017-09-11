stage('clone git repo') {
   node {
     git url: 'https://github.com/f5devcentral/f5-k8s-demo.git', branch:'1.1.1'
   }
}
stage('deploy Ingress iRule') {
   node {
     sh 'python iapps/deploy_iapp_bigip.py -r --iapp_name k8s_demo --strings=pool__addr=0.0.0.0 --pool_members 192.168.1.1:80 10.1.1.8 iapps/k8s_http.json'
   }
}
stage('update F5 Container Connector to use Cluster IP') {
    node {
        sh 'kubectl replace -f f5-cc-deployment-cluster.yaml'
	sh 'kubectl apply -f f5-ingress.yaml'
    }
}
stage('deploy website') {
    node {
        sh 'kubectl create -f my-website-deployment.yaml'
        sh 'kubectl create -f my-website-service.yaml'
        sh 'kubectl create -f my-website-configmap.yaml'
        sh './annotate-my-website.sh'
    }
}
stage ('deploy app1') {
    node {
        sh 'kubectl create -f app1-deployment.yaml'
        sh 'kubectl create -f app1-service.yaml'
        sh 'kubectl create -f app1-configmap-bad.yaml'
        sh './annotate-app1.sh app1-configmap-bad.yaml'
    }
}
stage ('deploy content routing / DNS') {
 node {
    sh 'python custom_automation.py  --host 10.1.10.60'   
 }   
}
stage ('verify content routing') {
    node {
        sh 'sleep 30'
        sh 'curl -H host:www.f5demo.com 10.1.10.80|grep "<title>F5 vLab</title>"'
        sh 'curl -H host:app1.f5demo.com 10.1.10.80|grep "App #1"'
    }
}

stage ('verify DNS') {
 node {
     sh 'sleep 30'
     sh 'dig @10.1.10.60 +short www.f5demo.com|grep 10.1.10.80'
     sh 'dig @10.1.10.60 +short app1.f5demo.com|grep 10.1.10.80'
     sh 'dig @10.1.10.60 +short my-frontend.f5demo.com|grep 10.1.10.81'
 }   
}
