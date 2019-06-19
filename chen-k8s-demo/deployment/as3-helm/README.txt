helm demo:

# just L4
helm install f5-as3 --name f5demo

# DNS
helm upgrade f5demo f5-as3 --set f5demo.dns=true

# WAF
helm upgrade f5demo f5-as3 --set f5demo.dns=true --set f5demo.http=true --set f5demo.waf=true

# delete AS3
helm upgrade f5demo f5-as3 --set f5demo.delete=true

# delete configmap
helm delete f5demo
