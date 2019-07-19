variable "vpc_id" {
  description = "VPC ID to assiciate the subnets"
}

variable "subnets" {
  description = "List of subnets to create"
  type        = "list"
}

variable "route_table_id" {
  description = "Route Table to Associate the subnets"
}


variable "environment" {
  description = "Environment"
  default     = "default"
}
