

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority 
}

output "eks-cluster-autoscaler-policy-count"{
value = length(aws_iam_policy.cluster_autoscaler_policy)
}
output "eks-cluster-policy-arn"{
  value = aws_iam_policy.cluster_autoscaler_policy.*.arn
}

output "eks_cluster_autoscaler_role_arn"{
    value = aws_iam_role.cluster_autoscaler_role.arn
}

 output "velero-iam-role-arn"{
   value=aws_iam_role.velero-backup-role.arn
 }
