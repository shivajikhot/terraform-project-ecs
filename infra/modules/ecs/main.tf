resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.environment}-task"
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  network_mode          = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "patient-service"
      image     = "${var.ecr_patient_repo_url}:latest"  # Dynamically use the ECR URL
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
    },
    {
      name      = "appointment-service"
      image     = "${var.ecr_appointment_repo_url}:latest"  # Dynamically use the ECR URL
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 3001
        hostPort      = 3001
      }]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "patient-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}
