output "Web_Public_IP" {
  value = "${aws_instance.web.public_ip}"
}
