# Safety tip:
# Use the attribute and value `sensitive = true` when needed
# (passwords, API keys, secret tokens...).
# However, remember that the `.tfstate file` contains even 
# the attribute values marked as sensitive.

variable "region" {  
  default = "eu-north-1"
}

# Replace `default` value with the real user name.
variable "user" {
  description = "Output for the `user` resource"
  type    = string
  default = "random_pet.pet_name.id"  
}
