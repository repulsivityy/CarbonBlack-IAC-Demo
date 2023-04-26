##############################################
## Credentials #
##############################################

variable "access_key" {
  type    = string
  default = "<enter access key here>"
}

variable "secret_key" {
  type    = string
  default = "<enter secret key here>"
}

variable "key_name" {
  type    = string
  default = "<enter key name here>"
}
variable "public_key" {
  type    = string
  default = "<enter public key string here>"
}

##############################################
## VPC related #
##############################################

# VPC variables
variable "appc_vpc" {
  type        = string
  description = "CIDR for App Control VPC"
  default     = "192.168.10.0/24"
}

# Subnet variables
variable "appc_subnet" {
  type        = string
  description = "CIDR for App Control subnet"
  default     = "192.168.10.0/24"
}


##############################################
## EC2 instances #
##############################################

variable "appc_ami" {
  type        = string
  description = "AMI instance"
  default     = "ami-0bc64185df5784cc3" #Win Server 2019 Base
}

variable "appc_instance" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Size (in Gb) of EBS volume"
  default     = 60
}

