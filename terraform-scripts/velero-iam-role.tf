data "aws_iam_policy_document" "velero_assume_role" {
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
        "system:serviceaccount:velero:${var.velero-sa-name}"
      ]
    }
  }
}

resource "aws_iam_role" "velero-backup-role" {
  name = "${var.velero_backup_role_name}"
  description = " For storing backup of k8s objects in s3 bucket using backup"
  assume_role_policy = data.aws_iam_policy_document.velero_assume_role.json
}

resource "aws_iam_policy_attachment" "velero-backup-policy-attachment" {
  name       = "${var.velero_backup_policy_name}-attachment"
  roles      = [aws_iam_role.velero-backup-role.name]
  policy_arn = aws_iam_policy.velero-backup-policy.arn
}
