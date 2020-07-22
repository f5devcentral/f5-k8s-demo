resource "random_string" "password" {
  length  = 10
  special = false
}

data "aws_ami" "f5_ami" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["${var.f5_ami_search_name}"]
  }
}
# resource "aws_network_interface" "bigip1_mgmt" {
#   subnet_id = "${module.vpc.private_subnets[0]}"
#   security_groups = ["${aws_security_group.f5.id}"]
#   private_ips = ["10.1.1.6"]
#   attachment {
#     instance = "${aws_instance.bigip1.id}"
#     device_index = 0
#   }
# }

resource "aws_network_interface" "bigip1_external" {
  subnet_id = "${module.vpc.private_subnets[0]}"
  security_groups = ["${aws_security_group.f5-ocp4-demo.id}"]
#  private_ips_count = 3
  private_ips = ["10.1.10.240", "10.1.10.242", "10.1.10.10","10.1.10.100","10.1.10.101","10.1.10.102"]
  attachment {
    instance = "${aws_instance.bigip1.id}"
    device_index = 1
  }
}

resource "aws_network_interface" "bigip1_internal" {
  subnet_id = "${module.vpc.private_subnets[1]}"
  security_groups = ["${aws_security_group.f5-ocp4-demo.id}"]
#  private_ips_count = 1
  private_ips = ["10.1.20.240", "10.1.20.242"]
  attachment {
    instance = "${aws_instance.bigip1.id}"
    device_index = 2
  }
}

resource "aws_eip" "bigip_mgmt_eip" {
  vpc                       = true
  instance = "${aws_instance.bigip1.id}"
}

resource "aws_instance" "bigip1" {
  availability_zone = "${var.aws_region}a"
  ami = "${data.aws_ami.f5_ami.id}"
   instance_type               = "m5.xlarge"
   subnet_id = "${module.vpc.public_subnets[0]}"
   vpc_security_group_ids = ["${aws_security_group.f5-ocp4-demo.id}"]
   private_ip = "10.1.1.6"

  user_data                   = "${data.template_file.bigip_init.rendered}"
  key_name                    = "${var.ssh_key}"
  root_block_device { delete_on_termination = true }

  iam_instance_profile = aws_iam_instance_profile.bigip_profile.name
  
  tags = {
    Name = "${var.prefix}-bigip1"
  }

}
