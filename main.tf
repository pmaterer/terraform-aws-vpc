data "aws_availability_zones" "available" {
    state = "available"
}

#
#   vpc
#

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = var.tags
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = var.tags
}

#
#   public subnets
#

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr_blocks)
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = false

    tags = var.tags
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = var.tags
}

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr_blocks)

    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
}


#
#   private subnets
#

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr_blocks)
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = false

    tags = var.tags
}

resource "aws_route_table" "private" {
    count = length(var.private_subnet_cidr_blocks)

    vpc_id = aws_vpc.main.id

    tags = var.tags
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidr_blocks)

    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

#
#   nat gateways
#

resource "aws_eip" "nat_gateway" {
    count = length(var.public_subnet_cidr_blocks)

    vpc = true

    tags = var.tags

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "main" {
    count = length(var.public_subnet_cidr_blocks)

    allocation_id = aws_eip.nat_gateway[count.index].id
    subnet_id = aws_subnet.private[count.index].id
    
    tags = var.tags

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route" "nat_gateway" {
    count = length(var.public_subnet_cidr_blocks)

    route_table_id = aws_route_table.private[count.index].id
    nat_gateway_id = aws_nat_gateway.main[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    depends_on = [
        aws_route_table.private
    ]
}

#
#   nacls
#

resource "aws_network_acl" "public" {
    vpc_id = aws_vpc.main.id
    subnet_ids = aws_subnet.public.*.id

    tags = var.tags
}

resource "aws_network_acl_rule" "public_egress_all" {
    network_acl_id = aws_network_acl.public.id
    rule_number = 100
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    egress = true
}

resource "aws_network_acl_rule" "public_ingress_all" {
    network_acl_id = aws_network_acl.public.id
    rule_number = 100
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    egress = false
}

resource "aws_network_acl" "private" {
    vpc_id = aws_vpc.main.id
    subnet_ids = aws_subnet.private.*.id

    tags = var.tags
}

resource "aws_network_acl_rule" "private_egress_all" {
    network_acl_id = aws_network_acl.private.id
    rule_number = 100
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    egress = true
}

resource "aws_network_acl_rule" "private_ingress_all" {
    network_acl_id = aws_network_acl.private.id
    rule_number = 100
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    egress = false
}