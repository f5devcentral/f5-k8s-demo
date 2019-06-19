sudo kubeadm init --apiserver-advertise-address 10.1.10.11 --pod-network-cidr 10.244.0.0/16 --service-cidr 10.166.0.0/16 --token-ttl 0 --node-name ip-10-1-10-11.us-west-2.compute.internal
