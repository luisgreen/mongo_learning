provider "aws" {
  region  = "us-west-2"
  profile = "mongo"
}

module "main_vpc" {
  source         = "../modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "Mongo Training VPC"
}

module "main_internet_gw" {
  source = "../modules/internet_gw"

  vpc_id = "${module.main_vpc.vpc_id}"
  name   = "Mongo Internet GW"
}

module "main_subnets" {
  source         = "../modules/subnet"
  vpc_id         = "${module.main_vpc.vpc_id}"
  subnets        = "${var.subnets}"
  route_table_id = "${module.main_internet_gw.route_table_id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "Allow SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${module.main_vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_mongo" {
  name        = "Allow Mongo"
  description = "Allow MongoDB inbound traffic"
  vpc_id      = "${module.main_vpc.vpc_id}"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "init" {
  template = "${file("../templates/mongo_user_data.tpl")}"
}

module "mongo_instances" {
  source   = "../modules/instance"
  key_name = "mongo_key"

  instances = [
    {
      name                   = "Mongo Master"
      ami                    = "ami-0cb72367e98845d43"
      instance_type          = "t3.small"
      subnet_id              = "${module.main_subnets.subnet_id[0]}"
      vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_mongo.id}"]
      user_data              = "${data.template_file.init.rendered}"
      private_ip             = "10.0.1.10"
    },
    # {
    #   name                   = "Mongo Node 1"
    #   ami                    = "ami-0cb72367e98845d43"
    #   instance_type          = "t3.small"
    #   subnet_id              = "${module.main_subnets.subnet_id[0]}"
    #   vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
    #   user_data              = "${data.template_file.init.rendered}"
    #   private_ip             = "10.0.1.11"
    # },
    # {
    #   name                   = "Mongo Node 2"
    #   ami                    = "ami-0cb72367e98845d43"
    #   instance_type          = "t3.small"
    #   subnet_id              = "${module.main_subnets.subnet_id[0]}"
    #   vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
    #   user_data              = "${data.template_file.init.rendered}"
    #   private_ip             = "10.0.1.12"
    # }
  ]
}
