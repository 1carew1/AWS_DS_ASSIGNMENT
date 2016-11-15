#!bin/bash

# This assumes that AWS CLI is configured and that the VPC is already set up and you only have 1 VPC
VPC_ID=$(aws ec2 describe-vpcs | grep VpcId | sed 's/"VpcId": "//g' | sed  's/",//g' | sed  's/ //g')
My_CURRENT_IP=$(wget http://ipinfo.io/ip -qO -)
WEB_SERVER_SECUTIY_GROUP="WServerSG"
DB_SECURITY_GRPUP="DatabaseSG"

aws ec2 create-security-group --group-name $WEB_SERVER_SECUTIY_GROUP --description "Web Servcer SG" --vpc-id $VPC_ID
aws ec2 create-security-group --group-name $DB_SECURITY_GRPUP --description "Database SG" --vpc-id $VPC_ID