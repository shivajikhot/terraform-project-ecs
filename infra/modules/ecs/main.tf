resource "aws_ecs_cluster" "openproject" {
  name = "openproject-ecs-cluster"
}

resource "aws_ecs_task_definition" "web" {
  family                = "openproject-web"
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  network_mode          = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "${var.ecr_patient_repo_url}:latest"  # Dynamically use the ECR URL
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
}

resource "aws_ecs_service" "web_service" {
  name            = "patient-service"
  cluster         = aws_ecs_cluster.openproject.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.patient_tg_arn
    container_name   = "web"
    container_port   = 8080
  }
}


resource "aws_ecs_task_definition" "worker" {
  family                   = "openproject-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
  execution_role_arn       = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "${var.ecr_patient_repo_url}:latest"
      command   = ["./docker/prod/worker"]
      memory    = 512
      cpu       = 256
      essential = true
    }
  ])
}

resource "aws_ecs_service" "worker" {
  name            = "openproject-worker"
  cluster         = aws_ecs_cluster.openproject.id
  task_definition = aws_ecs_task_definition.worker.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}
resource "aws_ecs_task_definition" "cron" {
  family                   = "${var.ecr_patient_repo_url}:latest"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
  execution_role_arn       = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  
  container_definitions = jsonencode([
    {
      name      = "cron"
      image     = "openproject/openproject:15-slim"
      command   = ["./docker/prod/cron"]
      memory    = 512
      cpu       = 256
      essential = true
    }
  ])
}

resource "aws_ecs_service" "cron" {
  name            = "openproject-cron"
  cluster         = aws_ecs_cluster.openproject.id
  task_definition = aws_ecs_task_definition.cron.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "seeder" {
  family                   = "openproject-seeder"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
  execution_role_arn       = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  
  container_definitions = jsonencode([
    {
      name      = "seeder"
      image     = "${var.ecr_patient_repo_url}:latest"
      command   = ["./docker/prod/seeder"]
      memory    = 512
      cpu       = 256
      essential = true
    }
  ])
}

resource "aws_ecs_service" "seeder" {
  name            = "openproject-seeder"
  cluster         = aws_ecs_cluster.openproject.id
  task_definition = aws_ecs_task_definition.seeder.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

