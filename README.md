Use the default branch jenkins_pipeline if you dont want to install prometheus and grafana. use prom_graphana branch if you wanna install prometheus and grafana.

# EKS cluster setup
This script creates an EKS Cluster.

This Jenkins job will: </br>
1. Creates 3 akamai security groups.
2. Creates 4 Target groups ( 2 for internal and 2 for external load balancers for ports 30080 and 30443).
3. Creates an EKS cluster.
4. Attaches 3 akamai security groups to the cluster.
5. Attches 4 target group to cluster's ASG.
6. Deploy ingress-nginx controller, cluster autoscaler, k8s dashboard using helm repo.
7. Velro configuration
8. RBAC

### Prerequisite:

1. An AMI that has nexus certificates.
2. A S3 bucket
3. A DynamoDB table with **LockID** as partion key of type string.

### Note:github url to create s3 bucket and dynamodb table: 
Docet-USA/Terraform-module-for-s3-data-replication at maintain-tfstate-in-s3 (worldpay.com)



# Instruction to run Jenkins job.

1. Create a jenkins job.
2. **Update below parameters in the jenkins job** </br>
       - email       </br>
       - branch      </br>
       - bucket_name                      </br>
       - dynamoDB_table_name              </br>
       - eks_cluster_name   &nbsp;&nbsp;  </br>
       - HELM_chart_name  &nbsp; - name of helm chart can only include lowercase , - and number. And name cannot be more than 53 characters </br>
       - tag_name_for_cluster                  </br>
       - desired_size        </br>
       - max_size                  </br>
       - min_size                  </br>
       - max_unavailable            </br>
       - instance_type                  </br>
       - region                          </br>
       - subnet_ids                       </br>
       - ec2_ssh_key                </br>
       - vpc_id                    </br>
       - sg_name                   </br>
       - aws_access_key_id               </br>
       - aws_secret_access_key                </br>
       - aws_session_token                </br>
       - target group name                </br>
       - aws_lb_internal_443_target_group_protcol - protcol for internal target group for port 443. Like TCP or TLS </br>

3. Select **terraform apply** option to create the resources. <br />
To destory the resources that are created , select **terraform destroy** option <br/>
4. Select **helm apply** option to deploy nginx-ingress controller, autoscalar and k8s dashboard pods.
To destory the resources that are created from helm command , select **helm delete** option <br/>
 


