data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*CentOS 8*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["125523088429"] # CentOS
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.small"
  private_ip    = "10.1.1.4"
  subnet_id = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.backend.id}"]
  key_name = "${var.ssh_key}"
  user_data = file("web_user_data.yml")

  tags = {
	Name = "${var.prefix}-web"
  }
}
