output "alb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name  # Fix reference
}

output "patient_tg_arn" {
  value = aws_lb_target_group.patient_tg.arn
}

output "appointment_tg_arn" {
  value = aws_lb_target_group.appointment_tg.arn
}
