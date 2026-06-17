# IAM role used by the EKS control plane
resource "aws_iam_role" "eks" {

  name = "${local.env}-${local.eks_name}-eks-cluster"

  # Trust policy: allows the EKS service to assume this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# Attach AWS-managed EKS Cluster Policy to the role
# Gives EKS the permissions needed to manage the cluster
resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# Create the EKS cluster (control plane)
resource "aws_eks_cluster" "eks" {

  name = "${local.env}-${local.eks_name}"
  version = local.eks_version

  # IAM role EKS will use
  role_arn = aws_iam_role.eks.arn

  vpc_config {

    # API endpoint accessible from the internet
    endpoint_public_access = true

    # No private endpoint access
    endpoint_private_access = false

    # Subnets where EKS networking resources will be created
    # Must be in at least 2 AZs
    subnet_ids = [
      aws_subnet.private1.id,
      aws_subnet.private2.id
    ]
  }

  access_config {

    # Use EKS API for authentication/authorization
    authentication_mode = "API"

    # Give cluster creator admin access automatically
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure policy is attached before creating cluster
  depends_on = [aws_iam_role_policy_attachment.eks]
}