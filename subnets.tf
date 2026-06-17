resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.zone1

  tags = {
    "Name" = "${local.env}-private1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}


resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.zone2

  tags = {
    "Name" = "${local.env}-private2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}


resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.64.0/19"
  availability_zone = local.zone1
  map_public_ip_on_launch = true

   tags = {
    "Name" = "${local.env}-public1"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.96.0/19"
  availability_zone = local.zone2
  map_public_ip_on_launch = true

   tags = {
    "Name" = "${local.env}-public2"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}