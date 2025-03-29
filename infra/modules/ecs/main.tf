resource "aws_ecs_cluster" "openproject" {
  name = "openproject-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_cloudwatch_log_group" "ecs_patient_logs" {
  name              = "/ecs/openproject"
  retention_in_days = 30
}
resource "aws_ecs_task_definition" "web" {
  family                = "openproject-web"
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  network_mode          = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "${var.ecr_openproject_repo_url}:latest"  
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      environment = [
        { name = "OPENPROJECT_HTTPS", value = "false" },
        { name = "OPENPROJECT_HOST__NAME", value = "${var.alb_dns_name}" },
        { name = "OPENPROJECT_HSTS", value = "true" },
        { name = "RAILS_CACHE_STORE", value = "memcache" },
        { name = "OPENPROJECT_CACHE__MEMCACHE__SERVER", value = "cache:11211" },
        { name = "DATABASE_URL", value = "postgres://postgres:Pr*de03kum1@devopsdatabase-instance-1.c61q0mwu08s7.us-east-1.rds.amazonaws.com:5432/postgres?pool=20&encoding=unicode&reconnect=true"},
        { name = "RAILS_MIN_THREADS", value = "4" },
        { name = "RAILS_MAX_THREADS", value = "16" },
        { name = "IMAP_ENABLED", value = "false" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "web"
        }
    }
   }
  ])

  requires_compatibilities = ["FARGATE"]
  memory                  = "2GB"
  cpu                     = "1 vCPU"
}

resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.openproject.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
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
      image     = "${var.ecr_openproject_repo_url}:latest"
      command   = ["./docker/prod/worker"]
      memory    = 512
      cpu       = 256
      essential = true
      environment = [
        { name = "OPENPROJECT_HTTPS", value = "false" },
        { name = "OPENPROJECT_HOST__NAME", value = "${var.alb_dns_name}" },
        { name = "OPENPROJECT_HSTS", value = "true" },
        { name = "RAILS_CACHE_STORE", value = "memcache" },
        { name = "OPENPROJECT_CACHE__MEMCACHE__SERVER", value = "cache:11211" },
        { name = "DATABASE_URL", value = "postgres://postgres:Pr*de03kum1@devopsdatabase-instance-1.c61q0mwu08s7.us-east-1.rds.amazonaws.com:5432/postgres?pool=20&encoding=unicode&reconnect=true"},
        { name = "RAILS_MIN_THREADS", value = "4" },
        { name = "RAILS_MAX_THREADS", value = "16" },
        { name = "IMAP_ENABLED", value = "false" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "worker"
        }
    }
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
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}
resource "aws_ecs_task_definition" "cron" {
  family                   = "${var.ecr_openproject_repo_url}:latest"
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
      environment = [
        { name = "OPENPROJECT_HTTPS", value = "false" },
        { name = "OPENPROJECT_HOST__NAME", value = "${var.alb_dns_name}" },
        { name = "OPENPROJECT_HSTS", value = "true" },
        { name = "RAILS_CACHE_STORE", value = "memcache" },
        { name = "OPENPROJECT_CACHE__MEMCACHE__SERVER", value = "cache:11211" },
        { name = "DATABASE_URL", value = "postgres://postgres:Pr*de03kum1@devopsdatabase-instance-1.c61q0mwu08s7.us-east-1.rds.amazonaws.com:5432/postgres?pool=20&encoding=unicode&reconnect=true"},
        { name = "RAILS_MIN_THREADS", value = "4" },
        { name = "RAILS_MAX_THREADS", value = "16" },
        { name = "IMAP_ENABLED", value = "false" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "cron"
        }
    }
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
    subnets          = var.private_subnet_ids
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
      image     = "${var.ecr_openproject_repo_url}:latest"
      command   = ["./docker/prod/seeder"]
      memory    = 512
      cpu       = 256
      essential = true
      environment = [
        { name = "OPENPROJECT_HTTPS", value = "false" },
        { name = "OPENPROJECT_HOST__NAME", value = "${var.alb_dns_name}" },
        { name = "OPENPROJECT_HSTS", value = "true" },
        { name = "RAILS_CACHE_STORE", value = "memcache" },
        { name = "OPENPROJECT_CACHE__MEMCACHE__SERVER", value = "cache:11211" },
        { name = "DATABASE_URL", value = "postgres://postgres:Pr*de03kum1@devopsdatabase-instance-1.c61q0mwu08s7.us-east-1.rds.amazonaws.com:5432/postgres?pool=20&encoding=unicode&reconnect=true"},
        { name = "RAILS_MIN_THREADS", value = "4" },
        { name = "RAILS_MAX_THREADS", value = "16" },
        { name = "IMAP_ENABLED", value = "false" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "seeder"
        }
    }
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
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

