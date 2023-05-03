resource "aws_iam_role" "eks_cluster" {
  name = var.iam_role_name_for_eks_cluster

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}



resource "aws_eks_cluster" "aws_eks" {
  name     = var.eks_cluster_name
  version  = "1.23"
  enabled_cluster_log_types    = ["api","audit","authenticator","controllerManager","scheduler"]
  role_arn = aws_iam_role.eks_cluster.arn
   vpc_config {
   subnet_ids = var.subnet_ids
   endpoint_private_access = true
   endpoint_public_access = false
   #security_group_ids = [module.security_group[0].id] #additional security group to the cluster
  }

  tags = {
    Name = var.tag_name_for_cluster
  }
}
  
###Adding add ons
    
# install  aws-ebs-csi-driver   
resource "aws_eks_addon" "aws-ebs-csi-driver" {
  addon_name   = "aws-ebs-csi-driver"
  cluster_name = var.eks_cluster_name
  depends_on = [
    aws_eks_cluster.aws_eks
  ]
}

# install    kube-proxy
resource "aws_eks_addon" "kube-proxy" {
  addon_name   = "kube-proxy"
  cluster_name = var.eks_cluster_name
  depends_on = [
    aws_eks_cluster.aws_eks
  ]
}

# install   vpc-cni  
resource "aws_eks_addon" "vpc-cni" {
  addon_name   = "vpc-cni"
  cluster_name = var.eks_cluster_name
  depends_on = [
    aws_eks_cluster.aws_eks
  ]
}    

# Node group - IAM role
resource "aws_iam_role" "eks_nodes" {
  name = var.iam_role_name_for_eks_nodes
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

### attaching below policies to the nodegroup IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodes.name
}




resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids = var.subnet_ids
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  tags = {
     "k8s.io/cluster-autoscaler/${aws_eks_cluster.aws_eks.name}" = "owned"
     "k8s.io/cluster-autoscaler/enabled" = "true"
     "Enviroment" = var.tag_name_for_cluster

  }
   launch_template {
   name = aws_launch_template.eks_launch_template.name
   version = aws_launch_template.eks_launch_template.latest_version
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEBSCSIDriverPolicy
  ]
}


resource "aws_launch_template" "eks_launch_template" {
  name = var.template_name
  image_id = var.ami_id
  vpc_security_group_ids = [module.security_group[0].id,module.security_group[1].id,module.security_group[2].id,aws_eks_cluster.aws_eks.vpc_config[0].cluster_security_group_id]
  instance_type = var.instance_type
  key_name = var.ec2_ssh_key
   tag_specifications {
    resource_type = "instance"

    tags = {
      Name                        = var.instances_name
     "k8s.io/cluster-autoscaler/${aws_eks_cluster.aws_eks.name}" = "owned"
     "k8s.io/cluster-autoscaler/enabled" = "true"

    }
  }

  user_data = base64encode(templatefile("userdata.tpl", { CLUSTER_NAME = var.eks_cluster_name, B64_CLUSTER_CA = aws_eks_cluster.aws_eks.certificate_authority[0].data, API_SERVER_URL = aws_eks_cluster.aws_eks.endpoint }))
}
    
    
