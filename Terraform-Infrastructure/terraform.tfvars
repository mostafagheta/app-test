# AWS Region
aws_region = "eu-central-1"

# EKS Cluster Configuration
clustername        = "myapp-eks-cluster"
kubernetes_version = "1.36"

# VPC Network Configuration
vpc_cidr_block             = "10.0.0.0/16"
private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

# EKS Endpoint Access
endpoint_private_access      = true
endpoint_public_access       = false
endpoint_public_access_cidrs = ["0.0.0.0/0"]

# EKS Node Group Configuration
node_group_config = {
  instance_types = ["m7i-flex.large"]
  ami_type       = "AL2023_x86_64_STANDARD"
  min_size       = 1
  max_size       = 5
  desired_size   = 3
}

# Bastion Host Configuration
bastion_instance_type       = "t3.medium"
key_pair_name               = "myapp-bastion-key"
bastion_allowed_cidr_blocks = ["0.0.0.0/0"]


# Common Resource Tags
common_tags = {
  Environment = "dev"
  Project     = "EKS-Cluster"
  ManagedBy   = "Terraform"
}
