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
# import_template_bigip.py -- Import an iApp template to a BIG-IP system using the iControl-REST API
# Documentation: see README.import_template_bigip
import requests
try:
	requests.packages.urllib3.disable_warnings()
except:
	pass

import json
import argparse
import os
import sys

# Setup and process arguments
parser = argparse.ArgumentParser(description='Script to import an iApp template to a BIG-IP device')
parser.add_argument("host",             help="The IP/Hostname in <host>[:<port>] format of the BIG-IP device")
parser.add_argument("name",             help="The name iApp template")
parser.add_argument("-a", "--apl",      help="The path to the iApp apl layer file to import",            default="iapp.apl")
parser.add_argument("-c", "--checkonly",help="Only check to see if a template existings on the device",  action="store_true")
parser.add_argument("-d", "--dontsave", help="Don't automatically save the config",                      action="store_true")
parser.add_argument("-i", "--impl",     help="The path to the iApp implementation layer file to import", default="iapp.tcl")
parser.add_argument("-m", "--macro",    help="The path to the iApp HTML help file to import",            default="iapp.macro")
parser.add_argument("-n", "--html",     help="The path to the iApp HTML help file to import",            default="iapp.html")
parser.add_argument("-o", "--overwrite",help="Overwrite an existing template definitions",               action="store_true")
parser.add_argument("-p", "--password", help="The BIG-IP password",                                      default="admin")
parser.add_argument("-r", "--modules",  help="The BIG-IP TMOS modules required (ex: ltm,gtm)",           default="")
parser.add_argument("-u", "--username", help="The BIG-IP username",                                      default="admin")
parser.add_argument("-v", "--minver",   help="The minimum version of BIG-IP TMOS required",              default="11.0.0")
parser.add_argument("-x", "--maxver",   help="The maximum version of BIG-IP TMOS required",              default="")
parser.add_argument("--password-file",   help="The BIG-IP password stored in a file", dest='password_file')
args = parser.parse_args()

password = args.password
if args.password_file:
        password = open(args.password_file).readline().strip()
# Create request session, set credentials, allow self-signed SSL cert
s = requests.session()
s.auth = (args.username, password)
s.verify = False

# Set our REST urls
template_url       = "https://%s/mgmt/tm/sys/application/template" % (args.host)
save_url           = "https://%s/mgmt/tm/sys/config" % (args.host)
template_exist_url = "%s/%s" % (template_url, args.name)
definition_url     = "%s/actions/definition" % (template_exist_url)

# Check to see if the template with the name specified in the arguments exists on the BIG-IP device
resp = s.get(template_exist_url)

# Check to see if authentication succeeded
if resp.status_code == 401:
	print "[error] Authentication failed: %s" % (resp)
	sys.exit(1)

if args.checkonly:
	if resp.status_code == 200:
		# The template exists exit 1
		print "Template '%s' exists on %s" % (args.name, args.host)
		sys.exit(1)
	else:
		# Exit 0
		print "Template '%s' does not exist on %s" % (args.name, args.host)
		sys.exit(0)

# Get data from the file containing implementation layer TCL code (-i argument)
with open(args.impl) as impl:
	impl_data = impl.read()
impl.close()

# Get data from the file containing presentation layer APL code (-a argument)
with open(args.apl) as apl:
	apl_data = apl.read()
apl.close()

# OPTIONAL: Get data from the file containing HTML Help (-n argument)
try:
    with open(args.html) as help:
        help_data = help.read()
except IOError as error:
    	print "[warning] HTML Help file \"%s\" not found, setting to blank" % (args.html)
    	help_data = ""

# OPTIONAL: Get data from the file containing the iApp macro (-m argument)
try:
    with open(args.macro) as macro:
        macro_data = macro.read()
except IOError as error:
    	print "[warning] Macro file \"%s\" not found, setting to blank" % (args.macro)
    	macro_data = ""

# Setup our base JSON payload
template_payload = {}
template_payload["ignoreVerification"] = "false"
template_payload["totalSigningStatus"] = "not-all-signed"
template_payload["requiresBigipVersionMin"] = args.minver
template_payload["requiresBigipVersionMax"] = args.maxver
template_payload["requiresModules"] = args.modules.split(',')

# The template exists and the -o argument (overwrite) was not specified.  Print error and exit
if resp.status_code == 200 and not args.overwrite:
	print "[error] A template named \"%s\" already exists on BIG-IP \"%s\".  To overwrite please specify the '-o' flag" % (args.name, args.host)
	sys.exit(1)

# Template does not already exist, create it
if resp.status_code == 404:
	# Add in creation-specific JSON payload items
	template_payload["name"] = args.name
	template_payload["actions"] = [ {} ]
	template_payload["actions"][0]["name"] = "definition"
	template_payload["actions"][0]["roleAcl"] = [ "admin","manager","resource-admin" ]
	template_payload["actions"][0]["implementation"] = impl_data
	template_payload["actions"][0]["presentation"] = apl_data
	template_payload["actions"][0]["htmlHelp"] = help_data
	template_payload["actions"][0]["macro"] = macro_data

	# Send the REST call to create the template and print outcome
	resp = s.post(template_url, data=json.dumps(template_payload))
	if resp.status_code != requests.codes.ok:
		print "[error] Template creation failed: %s" % (resp.json())
		sys.exit(1)
	print "[success] Template \"%s\" created on BIG-IP \"%s\"" % (args.name, args.host)
# Template exists and args.overwrite (-o) is TRUE so we will modify the existing template
# We need to update in two steps:
#  1) Update base template properties { minver, maxver, modules }
#  2) Update the 'actions':[ {name:definition} ... ] subcollection with the new impl, apl, html and macro
else:
	headers = { "Content-Type":"application/json" }

	# Step 1
	resp = s.put(template_exist_url, data=json.dumps(template_payload), headers=headers)
	if resp.status_code != requests.codes.ok:
		print "[error] Base template properties update failed: %s" % (resp.json())
		sys.exit(1)

	# Step 2
	definition_payload = {}
	definition_payload["implementation"] = impl_data
	definition_payload["presentation"] = apl_data
	definition_payload["htmlHelp"] = help_data
	definition_payload["macro"] = macro_data

	resp = s.put(definition_url, data=json.dumps(definition_payload), headers=headers)
	if resp.status_code != requests.codes.ok:
		print "[error] Template definition properties update failed: %s" % (resp.json())
		sys.exit(1)

	print "[success] Template \"%s\" updated on BIG-IP \"%s\"" % (args.name, args.host)

# Save the config (unless -d option was specified)
save_payload = { "command":"save" }
if not args.dontsave:
	resp = s.post(save_url, data=json.dumps(save_payload))
	if resp.status_code != requests.codes.ok:
		print "[error] save failed: %s" % (resp.json())
		sys.exit(1)
	else:
		print "[success] Config saved"
