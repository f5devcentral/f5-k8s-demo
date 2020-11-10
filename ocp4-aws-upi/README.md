# Eric Chen's OpenShift 4 AWS UPI Demo

## summary

This will install OpenShift 4 in AWS with Terraform.

This will use the BIG-IP instead of NLB for the edge
load balancer

## requirements

-Linux box
-recent version of openssl
-aws CLI

## setup

Obtain the "pull secret" from: https://cloud.redhat.com/openshift/install/aws/user-provisioned

Copy the value into "install-config.yaml" and add your ssh key.

Create a directory "upi" and copy install-config.yaml into that directory.

Download the OpenShift installer (currently using 4.3.x) from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.22/

Run
```
./openshift-install --dir ocp4 create ignition-configs
```

Go into the terraform directory and create a file terraform.tfvars
```
# example
prefix="erchen"
# ssh key in the region that you specified
ssh_key="erchen"
aws_region="us-west-2"
# AMI id for RHOCS in that region
rhcos_ami = "ami-0d231993dddc5cd2e"
# only if you use platform aws
cluster_id = "dc1-cb85p"
# your IP address
allow_ip = "192.0.2.10/32"
```

```
terraform init
terraform plan
terraform apply -auto-approve
```

