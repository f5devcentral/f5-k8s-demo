cat <<EOF | kubectl apply -n istio-demo -f -
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "jwt-example"
spec:
  targets:
  - name: httpbin
  peers:
  - mtls: {}
  origins:
  - jwt:
      issuer: "https://issuer.f5demo.com"
      jwksUri: "http://10.1.10.11/jwks.json"
  principalBinding: USE_ORIGIN
