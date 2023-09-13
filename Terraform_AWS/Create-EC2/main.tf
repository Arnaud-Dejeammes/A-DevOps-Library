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

# resource "aws_key_pair" "ec2_key_pair" {
#   key_name   = "key-pair-${random_pet.pet_name.id}"
#   public_key = file("~/.ssh/id_rsa.pub")
# }


# `instance_purpose`: choose an appropriate descriptive name for the instance
# (web_server, database_server... Name in Terraform)
resource "aws_instance" "instance_purpose" {
  # Amazon Linux 2023 AMI (Free tier)
  ami           = "ami-065681da47fb4e433"
  instance_type = "t3.micro"

  # key_name      = aws_key_pair.ec2_key_pair.key_name

  # Name in AWS
  tags = {
    Name = "ec2-${random_pet.pet_name.id}"
    # Add up up to 49 more tags
    # Key = "Value"
  }

  # Volumes

  # Root device
  # (Default values: Type gp3 | Size 8 Gib | IOPS 3000) 
  root_block_device {
    # device_name = ""
    volume_size = 8
    # General purpose SDD: gp3, gp2
    # Provisioned IOPS SDD: s01, s02
    # Cold HDD: sc1
    # Throughtput Optimized HDD: st1
    # Magnetic: standatd
    volume_type = "standard"
  }
  
  # EBS
  # Necessary for `hibernation_options`
  # Free tier: up to 30 GB of EBS General Purpose (SSD) or Magnetic storage
  # block_device {
  #   device_name = ""
  #   volume_size = ""
  #   volume_type = ""
  #   delete_on_termination = true
  # }

  # ephemeral_block_device {

  # }

  # Resource and cost saving option
  # Save the RAM instance state (saved in EBS volume)
  # Put the instance in hibernation mode:
  # $ aws ec2 hibernate-instances --instance-ids INSTANCE_ID

  # !!!ISSUE TO FIX!!!
  # Error: Unsupported block type
  # on main.tf line 108, in resource "aws_instance" "instance_purpose":
  # 108:   hibernation_options {
  # Blocks of type "hibernation_options" are not expected here.

  # hibernation_options {
  #   configured = true
  # }
}

# Stop the instance:
# $ aws ec2 stop-instances --instance-ids INSTANCE_ID

# Start the instance (stop-instances, hibernate-instances):
# $ aws ec2 start-instances --instance-ids INSTANCE_ID

# Instance description
# $ aws ec2 describe-instances --instance-ids INSTANCE_ID
