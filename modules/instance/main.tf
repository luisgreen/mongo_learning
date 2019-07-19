resource "aws_instance" "machine" {
  count = "${length(var.instances)}"

  ami                    = "${lookup(var.instances[count.index], "ami")}"
  instance_type          = "${lookup(var.instances[count.index], "instance_type")}"
  subnet_id              = "${lookup(var.instances[count.index], "subnet_id")}"
  user_data              = "${lookup(var.instances[count.index], "user_data", null)}"
  vpc_security_group_ids = "${lookup(var.instances[count.index], "vpc_security_group_ids", null)}"
  private_ip             = "${lookup(var.instances[count.index], "private_ip", null)}"
  key_name               = "${var.key_name}"

  tags = {
    Name        = "${lookup(var.instances[count.index], "name")}"
    Environment = "${var.environment}"
    created_by  = "Terraform"
  }
}

