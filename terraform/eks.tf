# 1. IAM Role (The ID Badge)
# Even though LocalStack mocks permissions, EKS *requires* a role to exist 
# to pass the API validation check.
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# 2. The Cluster (The Brain)
resource "aws_eks_cluster" "main" {
  name     = "safari-bank-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.eks_subnet.id]
    security_group_ids = [aws_security_group.internal_trust.id]
  }

  # Dependency: Ensure the role exists before creating the cluster
  depends_on = [
    aws_iam_role.eks_cluster_role
  ]
}
