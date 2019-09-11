import sys
import os
import ssl
import tempfile
from urllib.parse import unquote
cert = input('Paste in encoded cert: ')
output = input('Output filename: ')
decoded_cert = unquote(cert)
print(decoded_cert)
f = open(output,'w')
f.write(decoded_cert)

