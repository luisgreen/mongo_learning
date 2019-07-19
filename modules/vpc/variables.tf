variable "vpc_cidr_block" {
  description = "IP Address Block to use on the VPC"
}

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "environment" {
  description = "Environment"
  default     = "default"
}
