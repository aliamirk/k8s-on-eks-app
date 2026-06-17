

# IAM role used by EKS worker nodes (EC2 instances)
resource "aws_iam_role" "nodes" {

  name = "${local.env}-${local.eks_name}-eks-nodes"

  # Trust policy: allows EC2 instances to assume this role
  # Every worker node launched in the node group will use it
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# Main worker node permissions
# Allows nodes to join and communicate with the EKS cluster
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Permissions required by the VPC CNI plugin
# Allows pods and nodes to manage ENIs and IP addresses
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Allows nodes to pull container images from ECR
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Managed EKS node group
# AWS will create and manage EC2 worker nodes for us
resource "aws_eks_node_group" "general" {

  cluster_name = aws_eks_cluster.eks.name
  version = local.eks_version
  node_group_name = "general"

  # IAM role assigned to each worker node
  node_role_arn = aws_iam_role.nodes.arn

  # Subnets where worker nodes will be launched
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  capacity_type = "ON_DEMAND"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 1
    max_size = 10
    min_size = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Ignore changes to desired_size made outside Terraform
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}