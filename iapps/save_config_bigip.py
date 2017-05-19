#!/usr/bin/python
# Copyright (c) 2017 F5 Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
# save_config_bigip.py -- Save the config a BIG-IP system using the iControl-REST API
# Documentation: see README.save_config_bigip.py
import json
import requests
import sys

try:
	requests.packages.urllib3.disable_warnings()
except:
	pass

import argparse

# Setup and process arguments
parser = argparse.ArgumentParser(description='Script to deploy an iApp to a BIG-IP device')
parser.add_argument("host",             help="The IP/Hostname in <host>[:<port>] format of the BIG-IP device")
parser.add_argument("-u", "--username", help="The BIG-IP username", default="admin")
parser.add_argument("-p", "--password", help="The BIG-IP password", default="admin")
parser.add_argument("--password-file",   help="The BIG-IP password stored in a file", dest='password_file')

args = parser.parse_args()

# Set our REST urls
save_url       = "https://%s/mgmt/tm/sys/config" % (args.host)

password = args.password
if args.password_file:
        password = open(args.password_file).readline().strip()

# Create request session, set credentials, allow self-signed SSL cert
s = requests.session()
s.auth = (args.username, password)
s.verify = False


# Save the config (unless -d option was specified)
save_payload = { "command":"save" }

resp = s.post(save_url, data=json.dumps(save_payload))

if resp.status_code == 401:
    print "[error] Authentication to %s failed" % (args.host)
    sys.exit(1)

if resp.status_code != requests.codes.ok:
	print "[error] save failed: %s" % (resp.json())
	sys.exit(1)
else:
	print "[success] Config saved"
