kubectl logs -n kube-system $(kubectl get po -n kube-system |grep bigip1-f5-bigip-ctlr |awk '{print $1}')
