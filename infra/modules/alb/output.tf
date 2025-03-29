output "alb_dns_name" {
  value = aws_lb.openproject_load_balancer.dns_name
}

output "patient_tg_arn" {
  value = aws_lb_target_group.openproject_web.arn
}
