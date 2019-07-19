variable "region" {
  default = "us-west-2"
}

variable "subnets" {
  default = [
    {
      subnet_cidr       = "10.0.1.0/24"
      availability_zone = "us-west-2a"
      name              = "Zona de Mongo"
    },
    {
      subnet_cidr       = "10.0.2.0/24"
      availability_zone = "us-west-2b"
      name              = "Zona de Mongo 2"
    },
  ]
}

