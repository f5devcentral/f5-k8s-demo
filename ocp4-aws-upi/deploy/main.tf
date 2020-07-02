provider "bigip" {
  address  = "https://${var.bigip1_ip}:443"
  username = "admin"
  password = "${file("../upi/auth/kubeadmin-password")}"
}

# deploy application using as3
resource "bigip_as3" "common" {
  as3_json    = "${file("common-as3.json")}"
  tenant_filter = "Common"
}

# deploy application using as3
resource "bigip_as3" "complete" {
  as3_json    = "${file("as3.json")}"
  depends_on  = [bigip_as3.common]  
}
