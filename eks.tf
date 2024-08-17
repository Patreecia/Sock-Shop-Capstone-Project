################################################################################
# EKS Module
################################################################################

data "aws_caller_identity" "current" {}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.project_name
  cluster_version = "1.30"

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    main = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      iam_role_additional_policies = {
          ec2_access = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      }


      min_size     = 5
      max_size     = 10
      desired_size = 5

    }
  }

    access_entries = {
    # One access entry with a policy associated
    user-access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

      policy_associations = {
        admin_user = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }


  tags = local.tags
}