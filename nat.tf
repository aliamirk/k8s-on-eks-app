

resource "aws_eip" "natgw-ip" {
  domain = "vpc"
  tags = {
    Name = "${local.env}-eip"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw-ip.id
  subnet_id = aws_subnet.public1.id

  tags = {
    Name = "${local.env}-nat"
  }

  depends_on = [ aws_internet_gateway.main ]
}