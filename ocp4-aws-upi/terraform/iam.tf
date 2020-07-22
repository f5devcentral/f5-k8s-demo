#
# Create IAM Role
#
data "aws_iam_policy_document" "bigip_role" {
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

resource "aws_iam_role" "bigip_role" {
  name               = format("%s-f5-demo-ocp4-bigip-role", var.prefix)
  assume_role_policy = "${data.aws_iam_policy_document.bigip_role.json}"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "bigip_profile" {
  name = format("%s-f5-demo-ocp4-bigip-profile", var.prefix)
  role = aws_iam_role.bigip_role.name
}

data "aws_iam_policy_document" "bigip_policy" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketTagging"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "bigip_policy" {
  name   = format("%s-bigip-policy", var.prefix)
  role   = aws_iam_role.bigip_role.id
  policy = data.aws_iam_policy_document.bigip_policy.json
}

data "template_file" "bigip_init" {
  template = "${file("bigip.tpl")}"

  vars = {
    password = "${random_string.password.result}"
    s3_bucket = "${aws_s3_bucket.s3_bucket.id}"
  }
}

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

