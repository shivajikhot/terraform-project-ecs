output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}
output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}
