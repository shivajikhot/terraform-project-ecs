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

resource "aws_lb_target_group" "patient_tg" {
  name     = "patient-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"      # Define the health check path
    protocol            = "HTTP"
    interval            = 30              # Health check interval (seconds)
    timeout             = 5               # Timeout for health check (seconds)
    healthy_threshold   = 3               # Consecutive healthy checks before considering healthy
    unhealthy_threshold = 3               # Consecutive unhealthy checks before considering unhealthy
    matcher             = "200"           # Health check response code (can be a specific code or range)
  }
}


resource "aws_lb_target_group" "appointment_tg" {
  name     = "appointment-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"      
    protocol            = "HTTP"
    interval            = 30             
    timeout             = 5               
    healthy_threshold   = 3               
    unhealthy_threshold = 3           
    matcher             = "200"          
  }
}

# Single ALB Listener on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 404
      content_type = "text/plain"
      message_body = "application not founf"
    }
  }
}
resource "aws_lb_listener_rule" "patient_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/patients"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg.arn
  }
}

resource "aws_lb_listener_rule" "appointment_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  condition {
    path_pattern {
      values = ["/appointments"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appointment_tg.arn
  }
}
