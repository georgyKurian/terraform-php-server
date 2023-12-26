resource "aws_lb_target_group" "app-1-lb-target-group" {
  name        = "app-1-lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app-1-vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    timeout             = 3
    unhealthy_threshold = 2
  }
}

# Load balancer
resource "aws_lb" "app-1-load_balancer" {
  name               = "app-1-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.app-1-public-subnets : subnet.id]
  security_groups    = [aws_security_group.load-balancer.id]

  # connection_logs {
  #   bucket  = aws_s3_bucket.app-1-access-log.id
  #   prefix  = "lb/connection-log"
  #   enabled = true
  # }

  access_logs {
    bucket  = aws_s3_bucket.app-1-access-log.id
    prefix  = "lb/access-log"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group_attachment" "ec2_target_group_attachment" {
  count            = length(aws_instance.app-1-servers)
  target_group_arn = aws_lb_target_group.app-1-lb-target-group.arn
  target_id        = element(aws_instance.app-1-servers.*.id, count.index)
  port             = 80
}

resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.app-1-load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-1-lb-target-group.arn
  }
}

# resource "aws_lb_listener" "lb_listener_https" {
#   load_balancer_arn = aws_lb.app-1-load_balancer.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = data.aws_iam_server_certificate.load_balancer_domian.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app-1-lb-target-group.arn
#   }
# }
