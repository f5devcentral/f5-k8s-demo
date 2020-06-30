#!/bin/bash
S3_BUCKET=$1
#echo "Waiting for /info endpoint to be available"
while true; do
    aws s3 ls ${S3_BUCKET}/admin.shadow &> /dev/null;
    if [ $? == 1 ]; then
	break
    fi
        #echo $?;
	    sleep 10;
done

