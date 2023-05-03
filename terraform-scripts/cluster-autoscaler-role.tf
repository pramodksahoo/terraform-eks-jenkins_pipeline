
data "aws_eks_cluster" "cluster" {
   depends_on = [
 aws_eks_cluster.aws_eks   
 ]
   name= var.eks_cluster_name
}



data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
   depends_on = [
 aws_eks_cluster.aws_eks   
 ]
}

# fetch cluster oidc provider and other details
module "oidc-provider-data" {
  source     = "reegnz/oidc-provider-data/aws"
  version    = "0.0.2"
  issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

locals {
  oidc_provider_arn  = module.oidc-provider-data.arn
  oidc_provider_name = module.oidc-provider-data.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        local.oidc_provider_arn,
      ]
    }
  condition {
     test     = "StringEquals"
     variable = "${local.oidc_provider_name}:aud"
     values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_name}:sub"
      values = [
        "system:serviceaccount:${var.eks_sa_namespace}:${var.cluster-autoscaler-sa-name}"
      ]
    }
  }
}


#create cluster autoscaler role
resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = var.cluster_autoscaler_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
     
     
resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [
aws_eks_cluster.aws_eks
]
}
