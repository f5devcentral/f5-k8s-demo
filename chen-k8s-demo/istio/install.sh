#!/bin/sh
helm template install/kubernetes/helm/istio --name istio --namespace istio-system \
 --set tracing.service.type=NodePort --set gateways.istio-ingressgateway.type=NodePort --set grafana.service.type=NodePort --set global.meshExpansion.enabled=true \
    --set security.selfSigned=false \
    --set kiali.enabled=true \
    --set "kiali.dashboard.jaegerURL=http://jaeger-query:16686" \
    --set "kiali.dashboard.grafanaURL=http://grafana:3000" \
    --values install/kubernetes/helm/istio/values-istio-demo-auth.yaml
