locals {
  load_balancer_name = "shiny-alb"
  load_balancer_type = "application"
  target_group_name  = "shiny-target-group"
  target_type        = "instance"
}

resource "aws_lb" "shiny_alb" {
  name               = local.load_balancer_name
  internal           = false
  load_balancer_type = local.load_balancer_type
  security_groups    = [aws_security_group.jacobs_task_security_group_tf.id]
  subnets = [
    aws_subnet.jacobs_public_subnet.id,
    aws_subnet.jacobs_public_subnet_2.id
  ]

  enable_deletion_protection = false

}

resource "aws_lb_listener" "shiny_alb_https_listener" {
  load_balancer_arn = aws_lb.shiny_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.jacobs_website_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shiny_alb_tg.arn
  }
}

resource "aws_lb_listener" "shiny_alb_http_listener" {
  load_balancer_arn = aws_lb.shiny_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "shiny_alb_certificate_attachment" {
  listener_arn    = aws_lb_listener.shiny_alb_https_listener.arn
  certificate_arn = aws_acm_certificate.jacobs_website_cert.arn

  depends_on = [
    aws_lb_listener.shiny_alb_http_listener, aws_lb_listener.shiny_alb_https_listener
  ]
}

resource "aws_lb_target_group" "shiny_alb_tg" {
  name        = local.target_group_name
  vpc_id      = aws_vpc.jacobs_vpc_tf.id
  target_type = local.target_type
  port        = 3838
  protocol    = "HTTP"

  health_check {
    enabled = true
    timeout = 29
  }
}
