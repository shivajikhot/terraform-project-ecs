resource "aws_lb" "application_load_balancer" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = slice(var.public_subnet_ids, 0, 2)
  enable_deletion_protection = false

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.environment}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  # Required for Fargate
  protocol_version = "HTTP1"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn  # FIXED REFERENCE
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}
