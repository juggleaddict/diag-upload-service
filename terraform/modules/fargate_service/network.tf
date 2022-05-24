
data "aws_vpc" "main" {
  filter {
    name   = "tag-value"
    values = ["${var.vpc_name}"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }
}

resource "aws_subnet" "public" {
  for_each          = var.public_subnets
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge(local.default_tags, { "Name" = "${var.service_name}-public-${each.value.az}" })
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge(local.default_tags, { "Name" = "${var.service_name}-private-${each.value.az}" })
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id
  tags   = merge(local.default_tags, { "Name" = "${var.service_name}-public" })
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id
  tags   = merge(local.default_tags, { "Name" = "${var.service_name}-private" })
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}


resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  subnet_id     = aws_subnet.public[local.nat_gateway_az].id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

