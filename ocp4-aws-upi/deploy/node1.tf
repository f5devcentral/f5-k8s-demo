

resource "aws_instance" "node1" {
  ami           = "${var.rhcos_ami}"
  instance_type = "m4.xlarge"
  private_ip    = "10.1.20.31"
  subnet_id = "${var.subnet_id}"  
  vpc_security_group_ids = ["${var.security_group}"]  
  key_name = "${var.ssh_key}"

  #user_data        = "${data.template_file.node1_init.rendered}"
  user_data         = "${file("../upi/worker.ign")}"
  root_block_device {
    delete_on_termination = true
    volume_type = "gp2"
    volume_size = 120
  }

  iam_instance_profile = "${var.iam_instance_profile_worker}"

  tags = {
	Name = "${var.prefix}-f5-ocp4-demo-node1"
	"kubernetes.io/cluster/${var.cluster_id}" = "shared"	
  }
}

#data "template_file" "node1_init" {
#  template = "${file("node.tpl")}"
#
#  vars = {
#    machine_config_url = "https://api-int.dc1.example.com:22623/config/master"
#  }
#}
