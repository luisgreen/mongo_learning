output "public_ips" {
  value = "${aws_instance.machine.*.public_ip}"
}

output "private_ips" {
  value = "${aws_instance.machine.*.public_ip}"
}
