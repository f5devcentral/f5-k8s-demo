kubectl apply -f ../istio/istio-1.2.2-crd.yaml
sleep 30
kubectl apply -f ../istio/istio-1.2.2.yaml
kubectl create ns istio-demo
kubectl label namespace istio-demo istio-injection=enabled
kubectl apply -f echo-deployment.yaml
kubectl apply -f my-echo-service.yaml
kubectl apply -f httpbin.yaml -n istio-demo
kubectl apply -f istio-service.yaml -n istio-system
kubectl -n istio-demo apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: MUTUAL
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      caCertificates: /etc/istio/ingressgateway-ca-certs/ca-chain.cert.pem
    hosts:
    - "httpbin.example.com"
EOF
kubectl apply -n istio-demo -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "httpbin.example.com"
  gateways:
  - httpbin-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        port:
          number: 8000
        host: httpbin
EOF

