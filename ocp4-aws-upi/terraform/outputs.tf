output "Web_Public_IP" {
  value = "${aws_instance.web.public_ip}"
}
output "Bigip1_Public_IP" {
  value = "${aws_instance.bigip1.public_ip}"
}

output "Workspace_Public_IP" {
  value = "${aws_instance.workspace.public_ip}"
}
