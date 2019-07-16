kubectl apply -f ../istio/istio-1.2.2-crd.yaml
sleep 30
kubectl apply -f ../istio/istio-1.2.2.yaml
kubectl create ns istio-demo
kubectl label namespace istio-demo istio-injection=enabled
kubectl apply -f echo-deployment.yaml
kubectl apply -f my-echo-service.yaml
kubectl apply -f httpbin.yaml -n istio-demo
kubectl apply -f istio-service.yaml -n istio-system
