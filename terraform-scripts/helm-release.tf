# resource "helm_release" "prometheus" {
#   name       = "prometheus" ##release name

#   repository = "https://charts.bitnami.com/bitnami"
  
#   chart      = "kube-prometheus" #offical- chart name
  
#   namespace = "monitoring"
#   create_namespace = "true"
 
#   values = [
#     file("../helm-config/prometheus-config-bitnami.yml")
#   ]
#   depends_on = [
#     aws_eks_cluster.aws_eks,
#     module.security_group_ports,
#     aws_eks_node_group.node
#   ]
# }

# resource "helm_release" "grafana" {
#   name       = "grafana"

#   repository = "https://charts.bitnami.com/bitnami"
  
#   chart      = "grafana"
  
#   namespace = "monitoring"
#   set {
#     name  = "grafana.extraEnvVars[0].value"
#     value = "https://${var.host_name}/grafana"
#   }
#   set {
#     name  = "ingress.hostname"
#     value = "${var.host_name}"
#   }
 
#   values = [
#     file("../helm-config/grafana-config-bitnami.yml")
#   ]
  
#   depends_on = [
#      aws_eks_cluster.aws_eks,
#      module.security_group_ports,
#      aws_eks_node_group.node,
#      helm_release.prometheus
#   ]
# }

# # resource "helm_release" "instana-agent" {
# #   name       = "instana-agent"
# #   repository = "https://agents.instana.io/helm"
# #   chart      = "instana"
# #   namespace = "instana-agent"
# #   create_namespace = "true"
# #   values = [
# #     file("../helm-config/instana-config.yml")
# #   ] 
# #   depends_on = [
# #     aws_eks_cluster.aws_eks,
# #       module.security_group_ports,
# #      aws_eks_node_group.node
# #   ]
# # }


resource "helm_release" "kubernetes-dashboard" {
  name       = "k8s-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace = "kubernetes-dashboard"
  create_namespace = "true"
  set {
    name  = "ingress.hosts[0]"
    value = "${var.host_name}"   
  }
  set {
    name  = "settings.clusterName"
    value = "${var.eks_cluster_name}"   
  }
  set {
    name  = "settings.defaultNamespace"
    value = "${var.namespace_name}"   
  }
  values = [
    file("../helm-config/k8s-dashboard-config.yml")
  ]  
  depends_on = [
    aws_eks_cluster.aws_eks,
    module.security_group_ports,
     aws_eks_node_group.node
  ]
}

resource "helm_release" "metric-server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace = "kube-system"  
  depends_on = [
    aws_eks_cluster.aws_eks,
    module.security_group_ports,
     aws_eks_node_group.node,
   
  ]
}  


resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx/"
  chart      = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = "true"
  values = [
    file("../helm-config/ingress-config.yml")
  ]  
  depends_on = [
    aws_eks_cluster.aws_eks,
    module.security_group_ports,
     aws_eks_node_group.node
  ]
}

resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler/"
  chart      = "cluster-autoscaler"
  namespace = "kube-system"
  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }
  #   annotate cluster iam role to cluster autoscaler service account
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.cluster_autoscaler_role.arn}"
  }
  values = [
    file("../helm-config/cluster-autoscaler-config.yml")
  ]  
  depends_on = [
    aws_eks_cluster.aws_eks,
    module.security_group_ports,
     aws_eks_node_group.node
  ]
}

  resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace = "velero"
  create_namespace = "true"
  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.bucket_name
  }
  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.region
  }
  set {
    name  = "configuration.volumeSnapshotLocation.config.region"
    value = var.region
  }
  
  #   annotate velero iam role to velero service account
  set {
    name  = "serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.velero-backup-role.arn}"
  }
  values = [
    file("../helm-config/velero-config.yml")
  ]  
  depends_on = [
    aws_eks_cluster.aws_eks,
    module.security_group_ports,
     aws_eks_node_group.node
  ]
}  
