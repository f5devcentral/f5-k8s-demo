#!/usr/bin/env bash

cd "${BASH_SOURCE%/*}"

wget --no-verbose -O demo-magic.sh https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh
chmod +x demo-magic.sh
. demo-magic.sh
TYPE_SPEED=15
DEMO_PROMPT="\u@\h:~# "
clear

#########################
#####   K8S Demo    #####
#########################
pe "docker ps"


#####################################
#####   Remove demo-magic.sh    #####
#####################################
rm demo-magic.sh


