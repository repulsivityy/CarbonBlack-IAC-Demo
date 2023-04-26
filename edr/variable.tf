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
variable "edr_vpc" {
  type        = string
  description = "CIDR for EDR VPC"
  default     = "192.168.20.0/24"
}

# Subnet variables
variable "edr_subnet" {
  type        = string
  description = "CIDR for EDR subnet"
  default     = "192.168.20.0/24"
}


##############################################
## EC2 instances #
##############################################

variable "edr_ami" {
  type        = string
  description = "AMI instance"
  default     = "ami-00d785f1c099d5a0e" #CentOS7 HVM
}

variable "edr_instance" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Size (in Gb) of EBS volume"
  default     = 60
}

