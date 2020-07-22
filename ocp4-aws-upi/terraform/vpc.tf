provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "${var.prefix}-f5-ocp4-demo"
  cidr = "10.1.0.0/16"

  azs            = ["${var.aws_region}a"]
  # , "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets = ["10.1.1.0/24"]

  private_subnets = ["10.1.10.0/24","10.1.20.0/24"]

  enable_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
  }
}


resource "aws_security_group" "f5-ocp4-demo" {
  name   = "${var.prefix}-f5-ocp4-demo"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "nginx" {
  name   = "${var.prefix}-nginx"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name   = "${var.prefix}-backend"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ip}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["10.1.10.10","10.1.0.2"]
}
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${module.vpc.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
