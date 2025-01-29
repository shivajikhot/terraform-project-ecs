output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.ids
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.ids
}
