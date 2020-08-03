#!/bin/bash
S3_BUCKET=$1
#echo "Waiting for /info endpoint to be available"
for x in `seq 1 60`; do
    aws s3 ls ${S3_BUCKET}/admin.shadow &> /dev/null;
    if [ $? == 1 ]; then
	rm -f admin.shadow;
	touch admin.shadow;
	exit 0; # all done
	break
    fi
        #echo $?;
	    sleep 10;
done
echo "did not finish BIG-IP"
exit 1
