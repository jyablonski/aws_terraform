locals {
  load_balancer_name = "nba-elt-alb"
  load_balancer_type = "application"
  target_group_name  = "nba-elt-target-group"
  target_type        = "instance"
}
