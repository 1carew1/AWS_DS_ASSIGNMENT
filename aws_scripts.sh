#!bin/bash

# This assumes that AWS CLI is configured and that the VPC is already set up and you only have 1 VPC
VPC_ID=$(aws ec2 describe-vpcs | grep VpcId | sed 's/"VpcId": "//g' | sed  's/",//g' | sed  's/ //g')
My_CURRENT_IP=$(wget http://ipinfo.io/ip -qO -)
WEB_SERVER_SECUTIY_GROUP="WServerSG"
DB_SECURITY_GRPUP="DatabaseSG"

# Set Up Web Server SG - allow port 22, 80, 8080 and 443 from this IP
WEB_SG_ID=$(aws ec2 create-security-group --group-name $WEB_SERVER_SECUTIY_GROUP --description "Web Servcer SG" --vpc-id $VPC_ID | grep GroupId | sed  's/"GroupId": "//g' | sed 's/"//g' | sed 's/"//g' )
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 22 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 80 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 443 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 8080 --cidr $My_CURRENT_IP/32

# Set Up DB SG - allow ssh from Web Server
DB_SG_ID=$(aws ec2 create-security-group --group-name $DB_SECURITY_GRPUP --description "Database SG" --vpc-id $VPC_ID | grep GroupId | sed  's/"GroupId": "//g' | sed 's/"//g' | sed 's/"//g' )
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID  --protocol tcp --port 22 --source-group $WEB_SG_ID

