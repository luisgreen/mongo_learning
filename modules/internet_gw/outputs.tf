output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "route_table_id" {
  value = "${aws_route_table.igw_rt.id}"
}
