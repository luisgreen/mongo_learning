variable "vpc_id" {
  description = "VPC ID to assiciate the subnets"
}

variable "name" {
  description = "Name of the IGW"
}

variable "environment" {
  description = "Environment"
  default     = "default"
}
