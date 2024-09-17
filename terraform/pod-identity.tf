resource "aws_iam_role" "pod-identity-role" {
  name = "pod-identity-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]

       Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "pod-identity-policy" {
  name = "pod-identity-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListAllMyBuckets", "s3:ListObjects", "s3:ListBucket"]
        Effect = "Allow"
        Resource = ["*"]
       }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pod-identity-attachment" {
  policy_arn = aws_iam_policy.pod-identity-policy.arn
  role = aws_iam_role.pod-identity-role.name
}

resource "aws_eks_pod_identity_association" "example" {
  cluster_name = module.eks.cluster_name
  role_arn = aws_iam_role.pod-identity-role.arn
  namespace = "default"
  service_account = "general-sa"
}
