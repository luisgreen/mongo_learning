resource "aws_subnet" "subnet" {
  count = "${length(var.subnets)}"

  vpc_id = "${var.vpc_id}"

  cidr_block              = "${lookup(var.subnets[count.index], "subnet_cidr")}"
  availability_zone       = "${lookup(var.subnets[count.index], "availability_zone")}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${lookup(var.subnets[count.index], "name")}"
    Environment = "${var.environment}"
    created_by  = "Terraform"
  }
}

resource "aws_route_table_association" "subnets_assoc" {
  count = "${length(var.subnets)}"

  subnet_id      = "${lookup(aws_subnet.subnet[count.index], "id")}"
  route_table_id = "${var.route_table_id}"
}
