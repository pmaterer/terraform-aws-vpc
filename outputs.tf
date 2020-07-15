output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws_subnets.public.*.id
}

output "private_subnet_ids" {
    value = aws_subnets.private.*.id
}