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
}


