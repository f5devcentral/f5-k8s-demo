kubectl delete -f istio-service.yaml -n istio-system
kubectl delete -f echo-deployment.yaml
kubectl delete -f my-echo-service.yaml
kubectl delete -f httpbin.yaml -n istio-demo
sleep 30
kubectl delete -f ../istio/istio-1.2.2.yaml
sleep 30
kubectl delete -f ../istio/istio-1.2.2-crd.yaml
kubectl delete ns istio-demo



