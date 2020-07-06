variable "aws_region" {
  description = "aws region (default is us-east-1)"
  default     = "us-east-1"
}
variable "prefix" {
  description = "unique prefix for tags"
}
variable "ssh_key" {
  description = "name of existing AWS ssh key"
}
variable "f5_ami_search_name" {
  description = "BIG-IP AMI name to search for"
  type        = string
  default     = "F5 BIGIP-15.1.* PAYG-Best 25Mbps*"
}
variable "rhcos_ami" {
  description = "AMI ID for RHCOS"
  type = string
}
variable "cluster_id" {}
