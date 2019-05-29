#!/usr/bin/env bash

cd "${BASH_SOURCE%/*}"

#wget --no-verbose -O demo-magic.sh https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh
#chmod +x demo-magic.sh
. demo-magic.sh
TYPE_SPEED=15
DEMO_PROMPT="\u@\h:~# "
clear

#########################
#####   K8S Demo    #####
#########################
TYPE_SPEED=300

printf "\033[32mScale the Coffee Deployment \033[0m\n"

pe "kubectl get po"
pe "kubectl scale deployment/coffee --replicas=10"
pe "kubectl scale deployment/tea --replicas=8"
pe "kubectl get po"

pe "kubectl -n nginx-ingress get po"
pe "kubectl -n nginx-ingress get deployment"

pe "kubectl -n nginx-ingress scale deployment/nginx-ingress --replicas=5"
pe "kubectl -n nginx-ingress get po"





