# WORK IN PROGRESS - DO NOT USE IF YOU ARE READING THIS MESSAGE

# Security best practices reminder:
# Do not hard-code credentials (AWS access key and secret key) in any Terraform configuration
# (Risks of secret leakage if the file is commited to a public version control system)
# Grant temporary security credentials

# AWS CLI
# $ aws configure
# AWS CLI credentials used by Terrafom when referenced in the `provider` block:
# > AWS Access Key ID:
# > AWS Secret Access Key ID:
# > Default region name:
# > Default output format: json

# Set environment variables
# (Beware: accessible in `$ cat ~/.aws/config` and `$ cat ~/.aws/credentials`, or using `nano`):
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY_ID=

# Delete access keys:
# (Specific key for an IAM user)
# $ aws iam delete-access-key --user-name `USER_NAME` --access-key-id `ACCESS_KEY_ID`
# (If a user name is not specified, it is implicity deduced by IAM from the access key)
# Delete locally the credentials:
# $ rm ~/.aws/credentials

provider "aws" {
  region = var.region  

  default_tags {
    tags = {
      Create-AWS-EC2 = "aws-EC2"
    }
  }
}

# Random Provider
# (random_id, raandom_integer, random_password, random_pet, random_shuffle, random_string, random_uuid)
resource "random_pet" "pet_name" {
  length    = 3
  separator = "-"
}

# `instance_purpose`: choose an appropriate descriptive name for the instance
# (web_server, database_server...)
resource "aws_instance" "instance_purpose" {
  # Amazon Linux 2023 AMI (Free tier)
  ami           = "ami-065681da47fb4e433"
  instance_type = "t3.micro"

  tags = {
    Name = "ec2-${random_pet.pet_name.id}"
    # Add up up to 49 more tags
    # Key = "Value"
  }
}

# Stop the instance:
# $ aws ec2 stop-instances --instance-ids INSTANCE_ID

# Start the instance:
# $ aws ec2 start-instances --instance-ids INSTANCE_ID

# Get instance description:
# $ aws ec2 describe-instances --instance-ids INSTANCE_ID

# Fetch instance key pair
# $ aws ec2 describe-instances --instance-ids i-0bf2c4a6771ef0471 \
#   --query 'Reservations[0].Instances[0].KeyName' \
#   --output text
