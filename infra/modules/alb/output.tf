output "alb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name  # Fix reference
}
