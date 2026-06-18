# Create the trust policy for the AWS Load Balancer Controller
# This defines who is allowed to assume the IAM role
data "aws_iam_policy_document" "aws_lbc" {

  statement {
    effect = "Allow"

    # Allow EKS pods using Pod Identity to assume this role
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    # Required actions for Pod Identity
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# IAM role used by the AWS Load Balancer Controller pod
resource "aws_iam_role" "aws_lbc" {

  name = "${aws_eks_cluster.eks.name}-aws-lbc"

  # Trust policy defined above
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

# IAM policy containing all permissions required by
# the AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lbc" {

  policy = file("./iam/AWSLoadBalancerController.json")
  name = "AWSLoadBalancerController"
}

# Attach the controller permissions to the IAM role
resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

# Connect the Kubernetes service account to the IAM role using EKS Pod Identity
resource "aws_eks_pod_identity_association" "aws_lbc" {

  cluster_name = aws_eks_cluster.eks.name
  namespace = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn = aws_iam_role.aws_lbc.arn
}

# Install AWS Load Balancer Controller using Helm
resource "helm_release" "aws_lbc" {

  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"
  version = "1.7.2"

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks.name
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "vpcId"
      value = aws_vpc.main.id
    }
  ]

  depends_on = [
    helm_release.cluster_autoscaler
  ]
}