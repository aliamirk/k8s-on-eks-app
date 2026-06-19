# Get information about the EKS cluster that was already created
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

# Get authentication token for connecting to the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

# Configure Helm provider to communicate with the Kubernetes cluster
# This allows Terraform to install/manage Helm charts inside EKS
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# test review agent