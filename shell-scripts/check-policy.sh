aws configure set aws_access_key_id $TF_VAR_access_key
aws configure set aws_secret_access_key $TF_VAR_secret_key
aws configure set aws_session_token $TF_VAR_aws_session_token

#policystatus=$(aws iam get-policy --policy-arn arn:aws:iam::119276831673:policy/policy-create  2>&1)
#policystatus=$(aws iam get-policy --policy-arn arn:aws:iam::119276831673:policy/AmazonEKSClusterAutoscalerPolicy  2>&1)
#var=null
#echo "${policystatus}"  
#if echo "${policystatus}"  | grep -q 'not found'
#then
#    echo "policy doesnt exists"
#    var="create"
#else
#    echo "policy exist"
#    var="nocreate"
#fi

#echo "policy-count = \"$var\"" >> terraform.tfvars


# policystatus=$(aws iam list-policies --query 'Policies[?PolicyName==`AmazonEKSClusterAutoscalerPolicy`].Arn' --output text  2>&1)
autscalerpolicystatus=$(aws iam list-policies --query "Policies[?PolicyName=='AmazonEKSClusterAutoscalerPolicy'].Arn" --output text  2>&1)
echo "${autscalerpolicystatus}"
var=null
# if echo "${policystatus}"  | grep -q 'AmazonEKSClusterAutoscalerPolicy'
if echo "${autscalerpolicystatus}"  | grep 'AmazonEKSClusterAutoscalerPolicy'
then
    echo "cluster autoscaler policy already exists in this account"
    var="nocreate"
    echo $var
else
    echo "cluster autscaler policy doesn't exists in the account, so create it"
    var="create"
    echo $var
fi

echo "cluster-autoscaler-policy-count = \"$var\"" >> ../terraform-scripts/terraform.tfvars

