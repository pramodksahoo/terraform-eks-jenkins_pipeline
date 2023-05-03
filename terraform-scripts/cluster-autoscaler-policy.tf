data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  count = "${var.cluster-autoscaler-policy-count == "create" ? 1 : 0}"
  name = var.cluster-autoscaler-policy-name
  description = "EKS cluster autoscaler policy"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource": "*",
        "Effect": "Allow"
    }
  ]

}
EOT



}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterAutoScalerPolicy" {

  
  policy_arn =  "${var.cluster-autoscaler-policy-count}" == "create" ? aws_iam_policy.cluster_autoscaler_policy[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster-autoscaler-policy-name}"
  
  role = aws_iam_role.cluster_autoscaler_role.name
}


