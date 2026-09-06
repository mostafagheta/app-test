resource "aws_iam_user" "eks_admin" {
  name = "${var.clustername}_admin"
  path = "/"
  tags = var.tags
}

resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

resource "aws_iam_policy" "eks_admin" {
  name        = "${var.clustername}_admin_policy"
  description = "Policy for EKS admin access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
         "eks:*",
          "iam:ListRoles",
          "iam:PassRole", 
          "iam:GetRole",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "eks_admin" {
  user       = aws_iam_user.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_role" "eks_admin_role" {
  name = "${var.clustername}-eks-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.eks_admin.arn
        }
      }
    ]
  })
  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "eks_admin_role" {
  policy_arn = aws_iam_policy.eks_admin.arn
  role       = aws_iam_role.eks_admin_role.name
}
resource "aws_iam_instance_profile" "eks_admin" {
  name = "${var.clustername}-manager-profile"
  role = aws_iam_role.eks_admin_role.name

  tags = var.tags
}

resource "aws_iam_role" "lb_controller_pod_identity" {
  name = "${var.clustername}-aws-lb-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "lb_controller_pod_identity" {
  name = "${var.clustername}-aws-lb-controller"
  role = aws_iam_role.lb_controller_pod_identity.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateServiceLinkedRole",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteTags",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeListenerAttributes",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetRulePriorities",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:TagResource",
        "elasticloadbalancing:UntagResource",
        "elasticloadbalancing:DeregisterTargets",
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "cognito-idp:DescribeUserPoolClient",
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL",
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "shield:DescribeProtection",
        "shield:GetSubscriptionState",
        "shield:DeleteProtection",
        "shield:CreateProtection",
        "shield:DescribeSubscription",
        "shield:ListProtections"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "external_secrets_pod_identity" {
  name = "${var.clustername}-external-secrets"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "external_secrets_pod_identity" {
  name = "${var.clustername}-external-secrets"
  role = aws_iam_role.external_secrets_pod_identity.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:ListSecrets"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = "*"
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = module.eks.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets_pod_identity.arn
}

resource "aws_eks_pod_identity_association" "aws_lb_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller_pod_identity.arn
}

resource "aws_eks_pod_identity_association" "velero" {
  cluster_name    = module.eks.cluster_name
  namespace       = "velero"
  service_account = "velero"
  role_arn        = aws_iam_role.velero_pod_identity.arn
}


# -----------------------------------------------------------------------------
# Argo CD Image Updater - Pod Identity
# -----------------------------------------------------------------------------
resource "aws_iam_role" "argocd_image_updater_pod_identity" {
  name = "${var.clustername}-argocd-image-updater"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "argocd_image_updater_pod_identity" {
  name = "${var.clustername}-argocd-image-updater"
  role = aws_iam_role.argocd_image_updater_pod_identity.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:ListTagsForResource"
        ]
        Resource = "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "argocd_image_updater" {
  cluster_name    = module.eks.cluster_name
  namespace       = "argocd"
  service_account = "argocd-image-updater"
  role_arn        = aws_iam_role.argocd_image_updater_pod_identity.arn
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "velero" {
  bucket = "${var.clustername}-velero-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name        = "${var.clustername}-velero"
    Environment = var.velero_environment
  })
}

resource "aws_s3_bucket_public_access_block" "velero" {
  bucket = aws_s3_bucket.velero.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "velero_pod_identity" {
  name = "${var.clustername}-velero"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "velero_pod_identity" {
  name = "${var.clustername}-velero"
  role = aws_iam_role.velero_pod_identity.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ]
      Resource = aws_s3_bucket.velero.arn
    }, {
      Effect = "Allow"
      Action = [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "${aws_s3_bucket.velero.arn}/*"
    }]
  })
}