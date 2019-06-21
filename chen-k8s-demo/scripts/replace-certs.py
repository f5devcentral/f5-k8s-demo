import requests
import json
import os
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--host")
parser.add_argument("--ca")
parser.add_argument("--cert")
parser.add_argument("--key")
args = parser.parse_args()
print(args)
USERNAME='admin'
PASSWORD='admin'
URL=args.host
VERIFY=False
CA=args.ca
CERT=args.cert
KEY=args.key

CA_OBJ='/mgmt/tm/sys/crypto/cert/~Common~' + CA
CERT_OBJ='/mgmt/tm/sys/crypto/cert/~Common~' + CERT
KEY_OBJ='/mgmt/tm/sys/crypto/key/~Common~' + KEY

AUTH_REQUEST={'username':USERNAME,
              'password':PASSWORD,
              'loginProviderName':'tmos'}

if not VERIFY:
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def _upload(host, session, fp):

    chunk_size = 512 * 1024
    headers = {
        'Content-Type': 'application/octet-stream'
    }

    fileobj = open(fp, 'rb')
    filename = os.path.basename(fp)
    if os.path.splitext(filename)[-1] == '.iso':
        uri = '%s/mgmt/cm/autodeploy/software-image-uploads/%s' % (host, filename)
    else:
        uri = '%s/mgmt/shared/file-transfer/uploads/%s' % (host, filename)

    size = os.path.getsize(fp)

    start = 0

    while True:
        file_slice = fileobj.read(chunk_size)
        if not file_slice:
            break

        current_bytes = len(file_slice)
        if current_bytes < chunk_size:
            end = size
        else:
            end = start + current_bytes

        content_range = "%s-%s/%s" % (start, end - 1, size)
        headers['Content-Range'] = content_range
        session.post(uri,
                     data=file_slice,
                     headers=headers)

        start += current_bytes

session = requests.Session()
session.verify = VERIFY

# authenticate

r = session.post("%s/mgmt/shared/authn/login" %(URL),data=json.dumps(AUTH_REQUEST))
payload = r.json()
token = payload['token']['token']
session.headers['X-F5-Auth-Token'] = token

# transaction
#r = session.post("%s/mgmt/tm/transaction" %(URL),data='{}')
#payload = r.json()
#transaction = payload['transId']


# check for files
for obj in [CA_OBJ, CERT_OBJ, KEY_OBJ]:
    r = session.get("%s%s" %(URL,obj))
    print(r)
# upload
for filename in [CA, CERT, KEY]:
    _upload(URL, session, filename)

# replace w/ transaction
#session.headers['X-F5-REST-Coordination-Id'] = str(transaction)

payload = {'command':'install',
           'name':CA,
           'from-local-file':'/var/config/rest/downloads/' + CA}
print(payload)
r = session.post("%s/mgmt/tm/sys/crypto/cert" %(URL),data=json.dumps(payload))
print(r.content)

payload = {'command':'install',
           'name':CERT,
           'from-local-file':'/var/config/rest/downloads/' + CERT}
r = session.post("%s/mgmt/tm/sys/crypto/cert" %(URL),data=json.dumps(payload))
print(r.content)

payload = {'command':'install',
           'name':KEY,
           'from-local-file':'/var/config/rest/downloads/' + KEY}
r = session.post("%s/mgmt/tm/sys/crypto/key" %(URL),data=json.dumps(payload))
print(r.content)

# executetransaction
#session.headers['X-F5-REST-Coordination-Id'] = None
#r = session.patch("%s/mgmt/tm/transaction/%s" %(URL, transaction),data='{"state":"VALIDATING"}')
#print(r.content)

# clean-up
for filename in [CA, CERT, KEY]:
    payload = {'command':'run',
               'utilCmdArgs':"/var/config/rest/downloads/%s" %(filename)}
    r = session.post("%s/mgmt/tm/util/unix-rm" %(URL),data=json.dumps(payload))
    print(r)

# delete auth token
r = session.delete("%s/mgmt/shared/authz/tokens/%s" %(URL,token))
