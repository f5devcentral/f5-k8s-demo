resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = "${var.prefix}-f5-ocp4-demo-s3bucket"
}
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"
  key = "bootstrap.ign"
  source = "../upi/bootstrap.ign"
}
# encrypt password sha512
resource "null_resource" "admin-shadow" {
  provisioner "local-exec" {
    command = "./admin-shadow.sh"
  }
}

resource "aws_s3_bucket_object" "password" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"
  key = "admin.shadow"
  source = "admin.shadow"
  depends_on = ["null_resource.admin-shadow"]
}
resource "null_resource" "wait_for_bigip" {
  provisioner "local-exec" {
    command = "./wait_for_bigip.sh ${aws_s3_bucket.s3_bucket.id}"
  }
  depends_on = ["aws_instance.bigip1"]
}
data "template_file" "tfvars" {
  template = "${file("../deploy/terraform.tfvars.example")}"
  vars = {
    bigip_ip = "${aws_instance.bigip1.public_ip}"
    prefix    = "${var.prefix}"
    ssh_key   = "${var.ssh_key}"
    aws_region = "${var.aws_region}"
    rhcos_ami = "${var.rhcos_ami}"
    subnet_id = "${module.vpc.private_subnets[1]}"
    security_group = "${aws_security_group.f5-ocp4-demo.id}"
    iam_instance_profile_bigip = aws_iam_instance_profile.bigip_profile.name
    iam_instance_profile_bootstrap = aws_iam_instance_profile.bigip_profile.name
    iam_instance_profile_control-plane = aws_iam_instance_profile.control-plane_profile.name
    iam_instance_profile_worker = aws_iam_instance_profile.bigip_profile.name
    s3_bucket =  "${aws_s3_bucket.s3_bucket.id}"
    cluster_id = "${var.cluster_id}"
  }
}

resource "local_file" "tfvars-deploy" {
  content = "${data.template_file.tfvars.rendered}"
  filename = "../deploy/terraform.tfvars"
}