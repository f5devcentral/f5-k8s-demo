#
# Create IAM Role
#
data "aws_iam_policy_document" "control-plane_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "control-plane_role" {
  name               = format("%s-f5-demo-ocp4-control-plane-role", var.prefix)
  assume_role_policy = "${data.aws_iam_policy_document.control-plane_role.json}"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "control-plane_profile" {
  name = format("%s-f5-demo-ocp4-control-plane-profile", var.prefix)
  role = aws_iam_role.control-plane_role.name
}

data "aws_iam_policy_document" "control-plane_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "control-plane_policy" {
  name   = format("%s-control-plane-policy", var.prefix)
  role   = aws_iam_role.control-plane_role.id
  policy = data.aws_iam_policy_document.control-plane_policy.json
}



resource "aws_instance" "cp1" {
  ami           = "ami-06f85a7940faa3217"
  instance_type = "m4.xlarge"
  private_ip    = "10.1.20.21"
  subnet_id = "${module.vpc.private_subnets[1]}"
  vpc_security_group_ids = ["${aws_security_group.f5-ocp4-demo.id}"]
  key_name = "${var.ssh_key}"

  #user_data        = "${data.template_file.cp1_init.rendered}"
  user_data        = "${file("../upi/master.ign")}"
  root_block_device { delete_on_termination = true }

  iam_instance_profile = aws_iam_instance_profile.control-plane_profile.name


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
