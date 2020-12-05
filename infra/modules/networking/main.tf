resource "aws_vpc" "main" {
  cidr_block = var.cidr-block
  tags       = var.tags
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private-subnets)
  availability_zone = element(var.availability-zones, count.index)
  cidr_block        = var.private-subnets[count.index]
  vpc_id            = aws_vpc.main.id
  tags              = var.tags
}

# Public subnets
resource "aws_subnet" "public" {
  count             = length(var.public-subnets)
  availability_zone = element(var.availability-zones, count.index)
  cidr_block        = var.public-subnets[count.index]
  vpc_id            = aws_vpc.main.id
  tags              = var.tags
}

# EIPs for NAT gateways
resource "aws_eip" "eips" {
  count = length(var.public-subnets)
  vpc   = true
  tags  = var.tags
}

# Put a NAT gateways in each public subnet
resource "aws_nat_gateway" "nat" {
  count         = length(var.public-subnets)
  allocation_id = element(aws_eip.eips.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags          = var.tags

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

# Create publc route tables
resource "aws_route_table" "public" {
  count  = length(var.availability-zones)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-public-%s-vpc",
        var.environment,
        element(var.availability-zones, count.index),
      )
    }
  )
}

# Create private route tables
resource "aws_route_table" "private" {
  count  = length(var.availability-zones)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-private-%s-vpc",
        var.environment,
        element(var.availability-zones, count.index),
      )
    }
  )
}

# Add default route to the public route table to allow traffic out to the Internet via Internet gateways
resource "aws_route" "public-default" {
  count                  = length(aws_route_table.public[*])
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  route_table_id         = aws_route_table.public[count.index].id
}

# Add default route to the private route tables to allow traffic out to the Internet via NAT gateways
resource "aws_route" "private-default" {
  count                  = length(aws_route_table.private[*])
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_nat_gateway.nat.*.id, count.index)
  route_table_id         = aws_route_table.private[count.index].id
}

# Associate routing tables to appropriate subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public-subnets)
  route_table_id = element(aws_route_table.public.*.id, count.index)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private-subnets)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}
