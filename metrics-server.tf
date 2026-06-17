# Install Metrics Server in the EKS cluster using Helm
# Metrics Server collects CPU and memory usage of nodes and pods

resource "helm_release" "metrics_server" {

  name = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"

  # Namespace where Metrics Server will be deployed
  # kube-system is used for Kubernetes system components
  namespace = "kube-system"
  version = "3.12.1"

  # Custom Helm values file
  # Used to override default chart configurations
  # Example: resource limits, arguments, replica count, etc.
  values = [
    file("${path.module}/values/metrics-server.yaml")
  ]

  # Make sure worker nodes exist before installing Metrics Server
  # Metrics Server runs as a pod, so it needs nodes available 
  depends_on = [
    aws_eks_node_group.general
  ]
}

