# https://www.densify.com/kubernetes-tools/terraform-eks/

# module "eks_k8s1" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "2.3.1"

#   cluster_version = "1.28"

#   cluster_name = "jacobs-k8s-cluster"
#   vpc_id       = "vpc-00000000"

#   subnets = ["subnet-00000001", "subnet-000000002", "subnet-000000003"]

#   cluster_endpoint_private_access = "true"
#   cluster_endpoint_public_access  = "true"

#   write_kubeconfig      = true
#   config_output_path    = "/.kube/"
#   manage_aws_auth       = true
#   write_aws_auth_config = true

#   map_users = [
#     {
#       user_arn = "arn:aws:iam::717791819289:user/jacob"
#       username = "user1"
#       group    = "system:masters"
#     },
#   ]

#   worker_groups = [
#     {
#       name                 = "workers"
#       instance_type        = "t2.large"
#       asg_min_size         = 3
#       asg_desired_capacity = 3
#       asg_max_size         = 3
#       root_volume_size     = 100
#       root_volume_type     = "gp2"
#       ebs_optimized        = false
#       key_name             = "all"
#       enable_monitoring    = false
#     },
#   ]

#   tags = {
#     Cluster = "k8s"
#   }
# }