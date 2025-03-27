output "ecs_cluster_id" {
  value = aws_ecs_cluster.openproject.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.web.arn
}
