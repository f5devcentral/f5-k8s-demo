#!/bin/sh
# generate sha512 encrypted password
openssl passwd -6 -salt f5f5 -in ../upi/auth/kubeadmin-password > admin.shadow
