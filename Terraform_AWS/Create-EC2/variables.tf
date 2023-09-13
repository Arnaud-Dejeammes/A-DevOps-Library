variable "region" {  
  default = "eu-north-1"
}

# Replace `default` value with the real user name
variable "user" {
  description = "Output for the `user` resource"
  type    = string
  default = "random_pet.pet_name.id"
}

# sensitive = true