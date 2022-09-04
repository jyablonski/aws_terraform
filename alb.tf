resource "aws_lb" "graphql_alb" {
  name               = "jyablonski-graphql-alb-dev"
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

resource "aws_lb_listener" "graphql_alb_https_listener" {
  load_balancer_arn = aws_lb.graphql_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.jacobs_website_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graphql_alb_tg.arn
  }
}

resource "aws_lb_listener_certificate" "graphql_alb_certificate_attachment" {
  listener_arn    = aws_lb_listener.graphql_alb_https_listener.arn
  certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
}

resource "aws_lb_target_group" "graphql_alb_tg" {
  name        = "jyablonski-graphql-tg-dev"
  vpc_id      = aws_vpc.jacobs_vpc_tf.id
  target_type = "lambda"

  health_check {
    enabled = false
    timeout = 29
  }
}

resource "aws_lambda_permission" "allow_alb_graphql_execution" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_graphql_api_lambda_function.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.graphql_alb_tg.arn
}


resource "aws_lb_target_group_attachment" "graphql_alb_attachment" {
  target_group_arn = aws_lb_target_group.graphql_alb_tg.arn
  target_id        = aws_lambda_function.jacobs_graphql_api_lambda_function.arn
}
