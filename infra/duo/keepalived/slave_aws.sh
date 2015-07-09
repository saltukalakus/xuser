#!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1 # Log all messages to syslog
EIP=52.28.178.87
INSTANCE_ID=i-9d370c53
echo "Keepalive: Hello from slave"
/usr/local/bin/aws ec2 disassociate-address --public-ip $EIP
/usr/local/bin/aws ec2 associate-address --public-ip $EIP --instance-id $INSTANCE_ID
