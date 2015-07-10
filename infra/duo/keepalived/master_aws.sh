#!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1 # Log all messages to syslog
EIP=#AUTO_REPLACE_EIP
INSTANCE_ID=#AUTO_REPLACE_INSTANCE_ID
echo "Keepalive: Hello from master"
/usr/local/bin/aws ec2 disassociate-address --public-ip $EIP
/usr/local/bin/aws ec2 associate-address --public-ip $EIP --instance-id $INSTANCE_ID