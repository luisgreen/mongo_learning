
variable "instances" {
  description = "List of instances to create"
  type        = "list"
}

variable "key_name" {
  description = "Key To use"
}


variable "environment" {
  description = "Environment"
  default     = "default"
}
