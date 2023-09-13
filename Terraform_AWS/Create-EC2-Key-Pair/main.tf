# WORK IN PROGRESS - DO NOT USE IF YOU ARE READING THIS MESSAGE

# Security best practices reminder:
# 
#   * Do not hard-code credentials (AWS access key and secret key) in any Terraform configuration
#     (risks of secret leakage if the file is commited to a public version control system).
#   * Create a `.gitignore` file containing the glob patterns `*.tfstate`, `*.tfstate.*`,
#     eventhough the directory is not a git directtory. The `*.tfstate` file indeed
#     stores all the attributes' value, even the ones marked as `sensitive`.
#   * Use remote storage solutions for the `.tfstate` if necessary.
#   * Grant temporary security credentials.

# AWS CLI
# $ aws configure
# AWS CLI credentials used by Terrafom when referenced in the `provider` block:
# > AWS Access Key ID:
# > AWS Secret Access Key ID:
# > Default region name:
# > Default output format: json

# Set environment variables
# $ export AWS_ACCESS_KEY_ID=
# $ export AWS_SECRET_ACCESS_KEY_ID=
# (Beware: the values can be accessible in
# `$ cat ~/.aws/config` and `$ cat ~/.aws/credentials`, or using `nano`)

# Delete access keys
# (Specific key for an IAM user)
# $ aws iam delete-access-key --user-name `USER_NAME` --access-key-id `ACCESS_KEY_ID`
# (If an user name is not specified, it is implicity deduced by IAM from the access key)
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

# EC2 ACCESS AND CONNECTION
resource "tls_private_key" "ec2_private_key" {
  # The private key generated by this resource is stored unencrypted in the state file.
  # Use of this resource for production deployments is then not recommended.
  # Instead, generate a private key file outside Terraform, with a third-party provider,
  # or with the command line `ssh-keygen -t rsa -b 2048 -f ~/.ssh/KEY_PAIR_NAME`
  # Make sure to keep the secret key confidential by any means.
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name    = "key-pair-${random_pet.pet_name.id}"
  public_key  = tls_private_key.ec2_private_key.public_key_openssh  
}

# KEY PAIR LOCAL STORAGE
# Use of local_file method to store and retrieve the key pair outside Terraform
# (the file shouldn't be accessibe for unauthorized people):
resource "local_file" "pem" {
  # abspath: expression that returns the filesystem path of the module where the expression is placed.
  filename = pathexpand("~/.ssh/key-pair-${random_pet.pet_name.id}.pem")
  # filename = abspath("~/.ssh/key-pair-${random_pet.pet_name.id}.pem")
  # filename  = abspath("${path.module}/key-pair-${random_pet.pet_name.id}")
  content   = tls_private_key.ec2_private_key.private_key_pem
  # Read and write for the owner only
  file_permission = "0600"  
  # public_key = file("~/.ssh/KEY_PAIR_NAME")
}

# Key pair file path (RSA Private Key):
output "key_pair_path" {
  value = pathexpand("~/.ssh/key-pair-${random_pet.pet_name.id}.pem")
  # sensitive = true
  # Generate an outputs message in the console once `terraform apply` is run:
  # key_pair_path = "C:\\Users\\admin\\.ssh\\key-pair-RANDOM-PET-NAME.pem"
}

# aws ec2 describe-key-pairs --key-names KEY_PAIR_NAME

# `instance_purpose`: choose an appropriate descriptive name for the instance
# (web_server, database_server... Name in Terraform)
resource "aws_instance" "instance_purpose" {
  # Amazon Linux 2023 AMI (Free tier)
  ami           = "ami-065681da47fb4e433"
  instance_type = "t3.micro"

  # Tenancy of an EC2 lauched within a VPC
    # `dedicated`: the instance runs on dedicated hardware from a single AWS account
    # (higher control, performance and security)
    # `default`: the instance shares the hardware with instances from other AWS account
    # (lower costs)
    instance_tenancy = "default"

  key_name      = aws_key_pair.ec2_key_pair.key_name

  # Name in AWS
  tags = {
    Name = "ec2-${random_pet.pet_name.id}"
    # Add up up to 49 more tags
    # Key = "Value"
  }

  # VOLUMES

  # Root device
  # (Default values: Type gp3 | Size 8 Gib | IOPS 3000) 
  root_block_device {
    # device_name = ""
    volume_size = 8
    # General purpose SDD: gp3, gp2
    # Provisioned IOPS SDD: s01, s02
    # Cold HDD: sc1
    # Throughtput Optimized HDD: st1
    # Magnetic: standard
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

# $ terraform init
# $ terraform plan
# $ terraform plan > ./DESTINATION_DIRECTORY_NAME/terraform_plan_$(date +"%Y%m%d_%H%M%S").json
# $ terraform apply

# Instance description
# $ aws ec2 describe-instances --instance-ids INSTANCE_ID

# Stop the instance:
# $ aws ec2 stop-instances --instance-ids INSTANCE_ID

# Start the instance (stop-instances, hibernate-instances):
# $ aws ec2 start-instances --instance-ids INSTANCE_ID
