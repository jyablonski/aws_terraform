locals {
  eks_cluster_name = "jacobs-eks-cluster"
  master_arn       = "arn:aws:iam::717791819289:user/jacob"
}

# # The following 2 data resources are used get around the fact that we have to wait
# # for the EKS cluster to be initialised before we can attempt to authenticate.
# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "default" {
#   name = module.eks.cluster_name
# }

# 2024-03-12 update
# this was close but the iam permissions were fucked and i couldnt apply roles via terraform;
# something to do with the terraform user who creates this infra
# and while applying the terraform user could never connect into the k8s cluster so apply kept timing out
# also this created in a private mode or something, had to use console to flip
# obv if you had vpn + nat gateways and shit setup you could connect locally to the private vpc
# but i flipped it to public via the console to connect
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.15.3"

#   cluster_name    = local.eks_cluster_name
#   cluster_version = "1.29"

#   vpc_id                    = aws_vpc.jacobs_vpc_tf.id
#   subnet_ids                = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]
#   create_aws_auth_configmap = false
#   manage_aws_auth_configmap = true


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

#   }

#   aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/jacobs-terraform-user"
#       username = "jacobs-terraform-user"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/jacob"
#       username = "jacob"
#       groups   = ["system:masters"]
#     },
#   ]

#   tags = {
#     Environment = "dev"
#     Terraform   = true
#   }
# }
