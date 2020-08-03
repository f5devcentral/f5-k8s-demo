resource "aws_instance" "cp1" {
  ami           = "${var.rhcos_ami}"
  instance_type = "m4.xlarge"
  private_ip    = "10.1.20.21"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.security_group}"]
  key_name = "${var.ssh_key}"

  #user_data        = "${data.template_file.cp1_init.rendered}"
  user_data        = "${file("../upi/master.ign")}"
  root_block_device { delete_on_termination = true }

  iam_instance_profile = "${var.iam_instance_profile_control-plane}"

  tags = {
	Name = "${var.prefix}-f5-ocp4-demo-control-plane"
	"kubernetes.io/cluster/${var.cluster_id}" = "shared"
  }
}

#data "template_file" "cp1_init" {
#  template = "${file("node.tpl")}"
#
#  vars = {
#    machine_config_url = "https://api-int.dc1.example.com:22623/config/master"
#  }
#}
