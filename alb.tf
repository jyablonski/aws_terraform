resource "aws_lb" "mlflow_alb" {
  name               = "jyablonski-mlflow-alb-dev"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jacobs_task_security_group_tf.id]
  subnets = [
    aws_subnet.jacobs_public_subnet.id,
    aws_subnet.jacobs_public_subnet_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_listener" "mlflow_alb_https_listener" {
  load_balancer_arn = aws_lb.mlflow_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.jacobs_website_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow_alb_tg.arn
  }
}

resource "aws_lb_listener_certificate" "mlflow_alb_certificate_attachment" {
  listener_arn    = aws_lb_listener.mlflow_alb_https_listener.arn
  certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
}

resource "aws_lb_target_group" "mlflow_alb_tg" {
  name     = "jyablonski-mlflow-tg-dev"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.jacobs_vpc_tf.id
}

resource "aws_lb_target_group_attachment" "mlflow_alb_attachment" {
  target_group_arn = aws_lb_target_group.mlflow_alb_tg.arn
  target_id        = aws_instance.jacobs_ec2_mlflow.id
  port             = 80
}
