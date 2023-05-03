pipeline {
  agent any
  tools {
      terraform "terraform"
  }
  options {
        ansiColor('xterm')
    }
          
  parameters {

     string(description: 'List of recipients to send email report', name: 'recipients', defaultValue: 'prashantika.k@fisglobal.com')
    string(description: 'repo branch_name', name: 'branch_name', defaultValue: 'jenkins_pipeline')

    
    string(name: 'Bucket_name' ,description: 'Bucket name, to store tfstate files', defaultValue: 'bucket-name')
    string(name: 'Dynamodb_table_name' ,description: 'DynamoDB table name, for locking tfstate files', defaultValue: 'table-name')
    

    string(name: 'TF_VAR_access_key' ,defaultValue: 'ACCESSKEY')
    string(name: 'TF_VAR_secret_key' ,defaultValue: 'SECRETKEY')
    string(name: 'TF_VAR_aws_session_token' ,defaultValue: 'TOKEN')
   
    string(name: 'TF_VAR_eks_cluster_name' ,defaultValue: 'eks-cluster-poc')
    string(name: 'TF_VAR_host_name',defaultValue: 'test.local',description: 'Name of the hostname for host feild in ingress rule')  
    string(name: 'APP_NAMESPACE' ,defaultValue: 'testing-ns',description: 'Name of the Namespace to be created inside the cluster')   

    string(name: 'Velero_bucket_name' ,defaultValue: 'velero-backup-poc',description: 'Bucket names for velero to store backups')
//     string(name: 'Velero_iam_role__name' ,defaultValue: 'velero-backup-poc',description: 'Bucket names for velero to store backups')
//     string(name: 'Velero_iam_policy_name' ,defaultValue: 'velero-backup-poc',description: 'Bucket names for velero to store backups')
    
    string(name: 'TF_VAR_environment' ,defaultValue: 'poc')
    
    string(name: 'TF_VAR_desired_size' ,defaultValue: '5')
    string(name: 'TF_VAR_max_size' ,defaultValue: '7')
    string(name: 'TF_VAR_min_size' ,defaultValue: '3')
    string(name: 'TF_VAR_max_unavailable' ,defaultValue: '2')
    
    string(name: 'TF_VAR_instance_type' ,defaultValue: 'm5.xlarge')

    string(name: 'TF_VAR_ami_id' ,defaultValue: 'ami-0105ef4c15c620dd3')
    
    string(name: 'TF_VAR_vpc_id' ,defaultValue: 'vpc-0d6b2fc805aea1e63')
    
    string(name: 'TF_VAR_region' ,defaultValue: 'us-east-1')
    
    string(name: 'TF_VAR_subnet1' ,defaultValue: 'subnet-092a1151cc795945f')
    string(name: 'TF_VAR_subnet2' ,defaultValue: 'subnet-0dfe614064171d7c0')
    string(name: 'TF_VAR_subnet3' ,defaultValue: 'subnet-0fdbedaec36cd9291')
    
    string(name: 'TF_VAR_Akamai_sg_name' ,defaultValue: 'poc-sg')
    
    string(name: 'TF_VAR_ec2_ssh_key' ,defaultValue: 'poc-pem')
    
    string(name: 'TF_VAR_aws_lb_target_group_name' ,defaultValue: 'poc-tg')
           
    string(name: 'aws_lb_internal_443_target_group_protcol', description: 'value can be TCP or TLS. Protol for internal target group of port 80443 ' ,defaultValue: 'TCP')
           
    //string(name: 'TF_VAR_EKS_ClusterAutoscalarPolicyName' ,defaultValue: 'new-policy') //new policy
//     string(name: 'TF_VAR_EKS_ClusterAutoscalarPolicyName' ,defaultValue: 'AmazonEKSClusterAutoscalerPolicy')// existing policy
   

    booleanParam(name: 'terraform_plan', defaultValue: false, description: 'Select to Run terraform plan command')
    booleanParam(name: 'terraform_apply', defaultValue: false, description: 'Select to Run terraform apply command')
     booleanParam(name: 'apply_rbac', defaultValue: false,description:'Select to create RBAC and Updates coredns configmap')
    booleanParam(name: 'delete_rbac',defaultValue: false,description: 'Select to delete resources created through helm commands')
    booleanParam(name: 'terraform_destroy', defaultValue: false, description: 'Select to Run terraform destroy command')
  }


   
   
    stages {
    stage('Checkout src') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/${branch_name}']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'LocalBranch', localBranch: "**"]], gitTool: 'Default', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'svc-usjenkins-devops', url: 'git@github.worldpay.com:Docet-USA/terraform-EKS.git']]])
      }
    }
      
    stage('check-policy'){
      steps {
        sh "pwd"
        echo "cd shell-scripts"
        dir('shell-scripts') {
           sh "pwd"
            sh 'echo > ../terraform-scripts/terraform.tfvars' // removes previous contents
            sh "sh check-policy.sh"
        }
      }
    }
   
   stage('copy credentails') {
      steps {
       
        sh 'ls -lart'    
        sh "pwd"
        echo "cd terraform-scripts"
        dir('terraform-scripts') {
             
              
              sh 'echo "access_key = \\"${TF_VAR_access_key}\\"" >> ./terraform.tfvars'
              sh 'echo "secret_key = \\"${TF_VAR_secret_key}\\"" >> ./terraform.tfvars'
              sh 'echo "aws_session_token = \\"${TF_VAR_aws_session_token}\\"" >> ./terraform.tfvars'


              sh 'echo "iam_role_name_for_eks_cluster = \\"${TF_VAR_eks_cluster_name}-cluster-role\\"" >> ./terraform.tfvars'
              sh 'echo "eks_cluster_name = \\"${TF_VAR_eks_cluster_name}\\"" >> ./terraform.tfvars'
              sh 'echo "tag_name_for_cluster = \\"${TF_VAR_environment}\\"" >> ./terraform.tfvars'
              sh 'echo "iam_role_name_for_eks_nodes = \\"${TF_VAR_eks_cluster_name}-node-role\\"" >> ./terraform.tfvars'
              sh 'echo "eks_node_group_name = \\"${TF_VAR_eks_cluster_name}-nodegroup\\"" >> ./terraform.tfvars'

              sh 'echo "desired_size = \\"${TF_VAR_desired_size}\\"" >> ./terraform.tfvars'
              sh 'echo "max_size = \\"${TF_VAR_max_size}\\"" >> ./terraform.tfvars'
              sh 'echo "min_size = \\"${TF_VAR_min_size}\\"" >> ./terraform.tfvars'
              sh 'echo "max_unavailable = \\"${TF_VAR_max_unavailable}\\"" >> ./terraform.tfvars'

              sh 'echo "instance_type = \\"${TF_VAR_instance_type}\\"" >> ./terraform.tfvars'
              sh 'echo "ami_id = \\"${TF_VAR_ami_id}\\"" >> ./terraform.tfvars'
              sh 'echo "template_name = \\"${TF_VAR_eks_cluster_name}-launch-template\\"" >> ./terraform.tfvars'
              sh 'echo "instances_name = \\"${TF_VAR_eks_cluster_name}\\"" >> ./terraform.tfvars'
              
              sh 'echo "bucket_name = \\"${Velero_bucket_name}\\"" >> ./terraform.tfvars'
              sh 'echo "velero_backup_policy_name = \\"${Velero_bucket_name}-policy\\"" >> ./terraform.tfvars'
              sh 'echo "velero_backup_role_name = \\"${Velero_bucket_name}-role\\"" >> ./terraform.tfvars'
          
              sh 'echo "vpc_id = \\"${TF_VAR_vpc_id}\\"" >> ./terraform.tfvars'
              sh 'echo "region = \\"${TF_VAR_region}\\"" >> ./terraform.tfvars'
               sh 'echo "sg_name = \\"${TF_VAR_Akamai_sg_name}\\""  >> ./terraform.tfvars'
              sh 'echo "subnet_ids = [\\"${TF_VAR_subnet1}\\",\\"${TF_VAR_subnet2}\\",\\"${TF_VAR_subnet3}\\"]" >> ./terraform.tfvars'

              sh 'echo "aws_lb_target_group_name = \\"${TF_VAR_aws_lb_target_group_name}\\"" >> ./terraform.tfvars'
              sh 'echo "aws_lb_internal_443_protocl = \\"${aws_lb_internal_443_target_group_protcol}\\"" >> ./terraform.tfvars'

              sh 'echo "ec2_ssh_key = \\"${TF_VAR_ec2_ssh_key}\\"" >> ./terraform.tfvars'

              sh 'echo "cluster_autoscaler_role_name = \\"${TF_VAR_eks_cluster_name}-oidc-role\\"" >> ./terraform.tfvars'
            
             sh 'echo "namespace_name= \\"${APP_NAMESPACE}\\"" >> ./terraform.tfvars'
              
             
        }
        
        sh "pwd"
        echo "cd ansible-scripts"
        dir('helm-config') {
                  sh "pwd"
              //ansible variables
              sh 'echo > ./vars.yaml' // removes previous contents
              sh 'echo "eks_cluster_name: ${TF_VAR_eks_cluster_name}" >> ./vars.yaml'
              sh 'echo "access_key: ${TF_VAR_access_key}" >> ./vars.yaml'
              sh 'echo "secret_key: ${TF_VAR_secret_key}" >> ./vars.yaml'
              sh 'echo "aws_session_token: ${TF_VAR_aws_session_token}" >> ./vars.yaml'
              sh 'echo "region: ${TF_VAR_region}" >> ./vars.yaml'
              sh 'echo "namespace_name: ${APP_NAMESPACE}" >> ./vars.yaml'
             
        }
    
      }
    }
    stage('Terraform Init') {
      
      steps {
        ansiColor('xterm') {
          
          sh "pwd"
          dir('terraform-scripts') {
              sh "pwd"
              sh label: '', script: 'terraform init -reconfigure -backend-config="access_key=${TF_VAR_access_key}" -backend-config="secret_key=${TF_VAR_secret_key}" -backend-config="token=${TF_VAR_aws_session_token}" -backend-config "bucket=${Bucket_name}" -backend-config "dynamodb_table=${Dynamodb_table_name}" -backend-config "key=$TF_VAR_environment/$TF_VAR_eks_cluster_name/terraform.tfstate" -backend-config "region=${TF_VAR_region}"'
             
          }          
       }
      }   
    }
      
   stage('Terraform plan') {
       when{
       expression { params.terraform_plan}
     }
      steps {
        ansiColor('xterm') {
          sh "pwd"
          dir('terraform-scripts') {
              sh "pwd"
              sh label: '', script: 'terraform plan'
          }
      }
      } 
       post {
        success {
          echo "terraform plan successful"
         
        }
        failure {
          echo "terraform plan failed"
        
        }
      }
    }
   
      
    stage('Terraform apply') {
       when{
       expression { params.terraform_apply}
     }
      steps {
        ansiColor('xterm') {
          sh "pwd"
          dir('terraform-scripts') {
              sh "pwd"
               sh label: '', script: 'terraform apply   --auto-approve'
        } 
      }
      } 
       post {
        success {
          echo "terraform apply successful"
         
        }
        failure {
          echo "terraform apply failed"
        
        }
      }
    }
   
//  stage('get-role-arn'){
//       steps {
//         sh "pwd"
//         echo "cd shell-scripts"
//         dir('shell-scripts') {
//            sh "pwd"
//            sh "sh get-role.sh"
//         }
//       }
//     }

       
 stage("apply rbac") {
    when{
       expression { params.apply_rbac}
    }  
   steps {
     ansiColor('xterm') {
        sh 'cd helm-config'
        dir('helm-config') {
          sh "pwd"
//           sh "aws eks update-kubeconfig --name ${TF_VAR_eks_cluster_name} --region ${TF_VAR_region}"
          sh "ansible-playbook   rbac-apply.yaml"
        } 
     }
   }
      
    post {
        success {
          echo "rbac delete successful" 
        }
        failure {
          echo "rbac delete failed"        
        } 
    } 
}   
                  
      
     stage('rbac delete') {
       when{
       expression { params.delete_rbac}
     }
      steps {
        ansiColor('xterm') {
          sh 'cd helm-config'
          dir('helm-config') {
            sh "pwd"
            sh "ansible-playbook   rbac-delete.yaml"
          }
      }
      } 
       post {
        success {
          echo "rbac delete successful"
         
        }
        failure {
          echo "rbac delete failed"
        
        }
      }
    } 
      
    stage('Terraform destroy') {
     when{
       expression { params.terraform_destroy}
     }
      steps {
        ansiColor('xterm') {
            sh "pwd"
            dir('terraform-scripts') {
              sh "pwd"
              sh label: '', script: 'terraform destroy --auto-approve'
            }
      }
      }
      post {
        success {
          echo "destroy successful"
         
        }
        failure {
          echo "destroy failed"
        
        }
      }
    }   
    
  }
}
      
