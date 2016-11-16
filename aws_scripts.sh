# Load private data from this file
source private_info.sh
# Private file is the uncommented following :
#VPC_ID='vpc-XXXXX'
#KEY_PAIR="XXXXXX"
#OWNER_ID="XXXXXX"
# This AMI ID is for the RabbitMQ Server
#AMI_ID="ami-XXXXXX"
#PUBLIC_SUBNET_1='subnet-XXXXX'

cleanup_sg_id() {
	CLEANED_SG_ID=$(echo $1 | grep GroupId | sed  's/"GroupId": "//g' | sed 's/"//g' | sed 's/"//g' | sed 's/}//g' | sed 's/{//g' | sed 's/ //g')
}

# This assumes that AWS CLI is configured and that the VPC is already set up and you only have 1 VPC
# Also assumes you have created a key pair and have a desired AMI
#echo 'Enter Your VPC Id'
#read VPC_ID
#aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
# Possible way of getting this id without specifying it directly?
#echo 'Enter Public Subnet Id'
#read PUBLIC_SUBNET_1
My_CURRENT_IP=$(wget http://ipinfo.io/ip -qO -)
WEB_SERVER_SECUTIY_GROUP="WServerSG"
DB_SECURITY_GRPUP="DatabaseSG"
DEFAULT_SG="DefaultVPCSG"


DEFAULT_SG_ID=$(aws ec2 create-security-group --group-name $DEFAULT_SG --description "Default SG" --vpc-id $VPC_ID)
cleanup_sg_id "$DEFAULT_SG_ID"
DEFAULT_SG_ID=$CLEANED_SG_ID
# Allow default to have all traffic open to other instances in the security group
aws ec2 authorize-security-group-ingress --group-id $DEFAULT_SG_ID --ip-permissions "[
                {
                    \"IpProtocol\": \"-1\",
                    \"IpRanges\": [],
                    \"UserIdGroupPairs\": [
                        {
                            \"UserId\": \"$OWNER_ID\",
                            \"GroupId\": \"$DEFAULT_SG_ID\"
                        }
                    ],
                    \"PrefixListIds\": []
                }
            ]"

# Set Up Web Server SG - allow port 22, 80, 8080 and 443 from this IP
WEB_SG_ID=$(aws ec2 create-security-group --group-name $WEB_SERVER_SECUTIY_GROUP --description "Web Servcer SG" --vpc-id $VPC_ID)
# Get the SG ID
cleanup_sg_id "$WEB_SG_ID"
WEB_SG_ID=$CLEANED_SG_ID
# Assign the Correct Permissions
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 22 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 80 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 443 --cidr $My_CURRENT_IP/32
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID  --protocol tcp --port 8080 --cidr $My_CURRENT_IP/32

# Set Up DB SG - allow ssh from Web Server
DB_SG_ID=$(aws ec2 create-security-group --group-name $DB_SECURITY_GRPUP --description "Database SG" --vpc-id $VPC_ID)
cleanup_sg_id "$DB_SG_ID"
DB_SG_ID=$CLEANED_SG_ID
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID  --protocol tcp --port 22 --source-group $WEB_SG_ID

# Launch an instance into Web
#aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --key-name $KEY_PAIR --security-group-ids $WEB_SG_ID --subnet-id $PUBLIC_SUBNET_1
