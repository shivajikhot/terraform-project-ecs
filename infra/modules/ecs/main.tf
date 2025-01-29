resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.environment}-task"
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  network_mode          = "awsvpc"
  container_definitions = jsonencode([{
    name      = "patient-service"
    image     = var.patient_service_image
    cpu       = 512
    memory    = 1024
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])

  requires_compatibilities = ["FARGATE"]
  memory                  = "1GB"
  cpu                     = "0.5 vCPU"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "patient-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [var.public_subnet_id]
    assign_public_ip = true
  }
}
