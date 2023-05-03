module "security_group" {
  count = length(var.security_groups)
  source = "git::https://github.worldpay.com/Docet-USA/security_group.git//security_group?ref=eks_cluster_sg" # path to the module which has terraform script to create sg
  vpc_id = var.vpc_id
  description = var.security_groups[count.index].description
  name = "${var.sg_name}-${count.index}"
  ingress_rules = var.security_groups[count.index].ingress_rules
  egress_rules = var.security_groups[count.index].egress_rules
}


module "security_group_ports" {
  source = "git::https://github.worldpay.com/Docet-USA/security_group.git//eks_cluster_sg_ports?ref=eks_cluster_sg" # path to the module which has terraform script to create sg
  aws_eks_cluster_sg_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  ingress_ports_tcp = var.ports
  ingress_cidr_tcp = var.cidr
}

