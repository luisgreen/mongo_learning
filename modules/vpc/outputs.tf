output "vpc_id" {
  value = "${aws_vpc.mongo_vpc.id}"
}

output "vpc_arn" {
  value = "${aws_vpc.mongo_vpc.arn}"
}
