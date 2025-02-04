resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_patient_logs" {
  name              = "/ecs/patient-service"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs_appointment_logs" {
  name              = "/ecs/appointment-service"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "xray_logs" {
  name              = "/ecs/X-Ray"
  retention_in_days = 30
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
      cpu       = 256
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-west-1"  # Set your AWS region
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/patient-service"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "appointment-service"
      image     = "${var.ecr_appointment_repo_url}:latest"  # Dynamically use the ECR URL
      cpu       = 256
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 3001
        hostPort      = 3001
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/appointment-service"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  {
      name      = "xray-daemon"
      image     = "amazon/aws-xray-daemon"
      cpu       = 50
      memory    = 128
      essential = true
      portMappings = [{ 
        containerPort = 2000
        hostPort      = 2000
        protocol      = "UDP"
       }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/X-Ray"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
}

resource "aws_ecs_service" "patient_service" {
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

  load_balancer {
    target_group_arn = var.patient_tg_arn
    container_name   = "patient-service"
    container_port   = 3000
  }
}

resource "aws_ecs_service" "appointment_service" {
  name            = "appointment-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.appointment_tg_arn
    container_name   = "appointment-service"
    container_port   = 3001
  }
}
