# locals {
#   eks_cluster_name = "jacobs-eks-cluster"
#   master_arn = "arn:aws:iam::717791819289:user/jacob"
# }

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.15.3"

#   cluster_name    = local.eks_cluster_name
#   cluster_version = "1.29"

#   vpc_id     = aws_vpc.jacobs_vpc_tf.id
#   subnet_ids = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]


#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"

#   }

#   eks_managed_node_groups = {
#     one = {
#       name = "node-group-1"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 3
#       desired_size = 1
#     }

#     two = {
#       name = "node-group-2"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 2
#       desired_size = 1
#     }
#   }

#   aws_auth_users = [
#     {
#       userarn  = local.master_arn
#       username = "jacob"
#       groups   = ["system:masters"]
#     }
#   ]
#   tags = {
#     Environment = "dev"
#     Terraform   = true
#   }
# }
