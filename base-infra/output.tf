output "vpc_id" {
  value = "${module.main_vpc.vpc_id}"
}

output "vpc_arn" {
  value = "${module.main_vpc.vpc_arn}"
}

output "vpc_subnets_ids" {
  value = "${module.main_subnets.subnet_id}"
}

output "vpc_subnets_names" {
  value = "${module.main_subnets.subnet_name}"
}

output "internet_gw_id" {
  value = "${module.main_internet_gw.igw_id}"
}

output "route_table_id" {
  value = "${module.main_internet_gw.route_table_id}"
}

output "aws_security_group_ssh" {
  value = "${aws_security_group.allow_ssh.id}"
}

output "aws_instances_ip" {
  value = "${module.mongo_instances.public_ips}"
}
