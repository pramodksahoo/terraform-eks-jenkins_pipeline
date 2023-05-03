#2 target groups of port 30080, one for internal and other for external
resource "aws_lb_target_group" "tg-30080" {
  count = 2
  name = "${count.index}" == 0 ? "${var.aws_lb_target_group_name}-internal-30080" : "${var.aws_lb_target_group_name}-external-30080"
  port     = 30080 #http
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

#1 target groups of port 30443 for external LB
resource "aws_lb_target_group" "external-tg-30443" {
  count = 1
  name =  "${var.aws_lb_target_group_name}-external-30443"
  port     = 30443 #https
  protocol = "TLS"
  vpc_id   = var.vpc_id
}

#1 target groups of port 30443 for internal LB
#either on TCP or TLS protocol

resource "aws_lb_target_group" "internal-tg-30443" {
  count = 1
  name = "${var.aws_lb_target_group_name}-internal-30443"
  port     = 30443 #https
  protocol = var.aws_lb_internal_443_protocl
  vpc_id   = var.vpc_id
}

#attach 4 target groups to cluster ASG
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_eks_node_group.node.resources[0].autoscaling_groups[0].name
  count = 2
  lb_target_group_arn    = aws_lb_target_group.tg-30080[count.index].arn
}
    
resource "aws_autoscaling_attachment" "asg_attachment_bar_external_30443" {
  autoscaling_group_name = aws_eks_node_group.node.resources[0].autoscaling_groups[0].name
  count = 1
  lb_target_group_arn    = aws_lb_target_group.external-tg-30443[count.index].arn
}
    
resource "aws_autoscaling_attachment" "asg_attachment_bar_internal_30443" {
  autoscaling_group_name = aws_eks_node_group.node.resources[0].autoscaling_groups[0].name
  count = 1
  lb_target_group_arn    = aws_lb_target_group.internal-tg-30443[count.index].arn
}    
