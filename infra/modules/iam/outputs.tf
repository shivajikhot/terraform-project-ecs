output "ecs_security_group_id" {
  value = aws_security_group.ecs_security_group.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
