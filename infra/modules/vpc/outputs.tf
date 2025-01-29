output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id[count.index]
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id[count.index]
}
