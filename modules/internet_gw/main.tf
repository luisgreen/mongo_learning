// ============ INTERNET GATEWAY ============

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    created_by  = "Terraform"
  }
}

// ============ ROUTE TABLE & ROUTES ============
resource "aws_route_table" "igw_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name        = "Default Route Table for ${var.name}"
    Environment = "${var.environment}"
    created_by  = "Terraform"
  }
}
