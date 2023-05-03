# aws configure set aws_access_key_id $TF_VAR_access_key
# aws configure set aws_secret_access_key $TF_VAR_secret_key
# aws configure set aws_session_token $TF_VAR_aws_session_token

# #TF_VAR_eks_cluster_name - terraform variable
# #autoscalerrolearn- shell variable
# autoscalerrolearn=$(aws iam list-roles --query "Roles[?RoleName=='${TF_VAR_eks_cluster_name}_oidc_role'].Arn" --output text  2>&1)

# echo "autoscaler cluster role arn $autoscalerrolearn"
# #autoscalerrolearnis ansible variable
# echo "autoscalerrolearn: $autoscalerrolearn"  >> ../helm-config/vars.yaml

        
