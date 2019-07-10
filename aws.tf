#VPC
resource "aws_vpc" "dev" {

  cidr_block           = "109.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "user09-final-vpc"
  }
}

#subnet
resource "aws_subnet" "user09pub_a" {
  vpc_id            = "${aws_vpc.dev.id}"
  availability_zone = "ap-northeast-1a"
  cidr_block        = "109.0.1.0/24"
  tags = {
    Name = "public-1a"
  }
}

resource "aws_subnet" "user09pub_b" {
  vpc_id            = "${aws_vpc.dev.id}"
  availability_zone = "ap-northeast-1a"
  cidr_block        = "109.0.2.0/24"
  tags = {
    Name = "public-1d"
  }
}

#IGW
resource "aws_internet_gateway" "user09-igw" {
  vpc_id = "${aws_vpc.dev.id}"
  tags = {
    Name = "user09-igw"
  }
}

#RT
resource "aws_route_table" "user09-route-table" {
  vpc_id = "${aws_vpc.dev.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.user09-igw.id}"
  }
  tags {
    Name = "user09-route-table"
  }
}
 
resource "aws_route_table_association" "my-subnet-associationa" {
  subnet_id      = "${aws_subnet.user09pub_a.id}"
  route_table_id = "${aws_route_table.user09-route-table.id}"
}

resource "aws_route_table_association" "my-subnet-associationb" {
  subnet_id      = "${aws_subnet.user09pub_b.id}"
  route_table_id = "${aws_route_table.user09-route-table.id}"
}


#NACL
resource "aws_default_network_acl" "user09_default" {
  default_network_acl_id = "${aws_vpc.dev.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    "${aws_subnet.user09pub_a.id}",
    "${aws_subnet.user09pub_b.id}",
  ]
  tags = {
    Name = "user09-nacldefault"
  }
}

#SG
resource "aws_default_security_group" "user09_default" {
  vpc_id = "${aws_vpc.dev.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

