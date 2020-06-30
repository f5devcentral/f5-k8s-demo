

resource "aws_instance" "bootstrap" {
  ami           = "ami-06f85a7940faa3217"
  instance_type = "i3.large"
  private_ip    = "10.1.20.11"
  subnet_id = "${module.vpc.private_subnets[1]}"
  vpc_security_group_ids = ["${aws_security_group.f5-ocp4-demo.id}"]
  key_name = "${var.ssh_key}"

  user_data        = "${data.template_file.bootstrap_init.rendered}"
  root_block_device { delete_on_termination = true }

  iam_instance_profile = aws_iam_instance_profile.bigip_profile.name


  tags = {
	Name = "${var.prefix}-bootstrap"
  }
}

data "template_file" "bootstrap_init" {
  template = "${file("bootstrap.tpl")}"

  vars = {
    s3_bucket = "${aws_s3_bucket.s3_bucket.id}"
  }
}
