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
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-west-1"  # Set your AWS region
        },
       {
          name  = "AWS_XRAY_TRACING_NAME"
          value = "appointment-service-trace"
       },
       {
          name  = "AWS_XRAY_DAEMON_ADDRESS"
          value = "xray.us-west-1.amazonaws.com:2000"
        },
       {
        name  = "AWS_XRAY_DAEMON_DISABLE_METADATA"
        value = "true"
       },
      {
       name  = "AWS_XRAY_DAEMON_NO_INSTANCE_ID"
       value = "true"
        }
      ]
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


##########MONITORING#####################################

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.environment}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = "512"
  memory                   = "1024"
  volume {
    name = "prometheus-config"
  }
  container_definitions = jsonencode([{
    name      = "s3-sync"
    image     = "amazon/aws-cli"
    command = [
       "s3", "cp", "s3://${aws_s3_bucket.prometheus_bucket.bucket}/prometheus.yml", "/etc/prometheus/prometheus.yml", "--debug"
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/s3-sync"
        awslogs-region        = "us-west-1"
        awslogs-stream-prefix = "ecs"
      }
    }
    mountPoints = [{
      sourceVolume  = "prometheus-config"
      containerPath = "/etc/prometheus"
    }]
    essential = false
  },
  {
    name      = "prometheus"
    image     = "prom/prometheus:latest"
    dependsOn = [{
      containerName = "s3-sync"
      condition     = "SUCCESS"
    }]
    cpu       = 256
    memory    = 512
    portMappings = [{
      containerPort = 9090
    }]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/prometheus"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    essential = true
    mountPoints = [{
      sourceVolume  = "prometheus-config"
      containerPath = "/etc/prometheus"
    }]
  }])
}


resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.environment}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{ containerPort = 3000 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/grafana"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "prometheus_service" {
  name            = "prometheus-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "grafana_service" {
  name            = "grafana-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}


resource "aws_s3_bucket" "prometheus_bucket" {
  bucket = "${var.environment}-prometheus-data"
}

resource "aws_s3_bucket_versioning" "prometheus_versioning" {
  bucket = aws_s3_bucket.prometheus_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_policy" "prometheus_s3_policy" {
  name        = "${var.environment}-prometheus-s3-policy"
  description = "Allows Prometheus to store data in S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.prometheus_bucket.arn,
          "${aws_s3_bucket.prometheus_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_s3_attachment" {
  role       = basename(var.task_role_arn)  # Attach to Prometheus task role
  policy_arn = aws_iam_policy.prometheus_s3_policy.arn
}

