provider "aws" {
   
   region     = var.region
   access_key = var.access_key
  secret_key = var.secret_key
  token = var.aws_session_token
   
 }
provider "aws" {
   alias = "sourced"
   region = var.region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.aws_eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.aws_eks.certificate_authority[0].data)
#      config_path = "~/.kube/config"
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
#     depends_on = [
#     aws_eks_cluster.aws_eks
#   ]
  }
}




