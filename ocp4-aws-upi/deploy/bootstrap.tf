

resource "aws_instance" "bootstrap" {
  ami           = "${var.rhcos_ami}"
#  instance_type = "i3.large"
  instance_type = "m4.xlarge"
  private_ip    = "10.1.20.11"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.security_group}"]
  key_name = "${var.ssh_key}"

  user_data        = "${data.template_file.bootstrap_init.rendered}"
  root_block_device { delete_on_termination = true }

  iam_instance_profile = "${var.iam_instance_profile_bootstrap}"


  tags = {
	Name = "${var.prefix}-bootstrap"
  }

  depends_on = ["bigip_as3.complete"]
}

data "template_file" "bootstrap_init" {
  template = "${file("bootstrap.tpl")}"

  vars = {
    s3_bucket = "${var.s3_bucket}"
  }
}
