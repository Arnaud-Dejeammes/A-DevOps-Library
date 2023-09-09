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
      Create-AWS-EC2 = "aws-iam-policy"
    }
  }
}

# Random Provider
# (random_id, raandom_integer, random_password, random_pet, random_shuffle, random_string, random_uuid)
resource "random_pet" "pet_name" {
  length    = 3
  separator = "-"
}

# Remember to replace `user-name` with the real user name in variables
resource "aws_iam_user" "new_user" {
  name = "var.user-name"
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

# Key pair (login)
provider "tls" {
}

resource "tls_private_key" "ssh_key_pair_private" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "tls_public_key" "ssh_key_pair_public" {
  private_key_pem = tls_private_key.example.private_key_pem
}

output "private_key" {
  value = tls_private_key.example.private_key_pem
}

output "tls_public_key" {
  value = tls_public_key.example.public_key_pem
}

# Access to private and public keys (after `$ terraform apply`):
# terraform output private_key
# terraform output public_key

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  acl = "private"
}

# POLICY

resource "aws_iam_policy" "policy" {
  name        = "${random_pet.pet_name.id}-policy"
  description = "My test policy"
  policy = data.aws_iam_policy_document.EC2_Full_Access.json
}

# AmazonEC2FullAccess
# "Version": "2012-10-17"
# Fetched on AWS Roles: 23/09/06

data "aws_iam_policy_document" "EC2_Full_Access" {
  statement {
    actions    = ["ec2:*"]
    effect    = "Allow"
    resource  = ["*"]
  }

  statement {
    effect    = "Allow"
    actions    = ["elasticloadbalancing:*"]
    resource  = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["autoscaling:*"]
    resource  = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resource = ["*"]
    condition {
      test      = "StringEquals"
      variable  = "iam:AWSServiceName"
      values    = [
        "autoscaling.amazonaws.com",
        "ec2scheduled.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com",
        "transitgateway.amazonaws.com"]
    }
  }
}

# Policy attachment
# iam_policy + iam_policy_document create a policy,
# but does not apply to any users or roles.
# To apply to users:
resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  # ARN: Amazon Resource Name
  policy_arn = aws_iam_policy.policy.arn
}
