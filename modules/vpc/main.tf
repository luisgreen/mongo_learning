resource "aws_vpc" "mongo_vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.vpc_name}"
    Environment = "${var.environment}"
    created_by  = "Terraform"
  }
}
