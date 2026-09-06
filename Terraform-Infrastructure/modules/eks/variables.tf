variable "clustername" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}
variable "vpc_cidr_block" {
  description = "VPC CIDR block for the EKS cluster"
  type        = string
  default     = "10.0.0.0/16"
}
variable "private_subnets_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}
variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}
variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}
variable "endpoint_public_access_cidrs" {
  description = "CIDRs for public access to the EKS cluster endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
// Removed eks_admin_role_arn and cluster_autoscaler_role_arn variables. IAM resources are now created inside the module.
variable "node_group_config" {
  description = "Configuration for the EKS managed node group"
  type = object({
    instance_types = list(string)
    ami_type       = string
    min_size       = number
    max_size       = number
    desired_size   = number
  })
  
}
variable "tags" {
  description = "Tags to apply to the EKS cluster and resources"
  type        = map(string)
  default     = {}
}
variable "oidc_providers" {
  description = "OIDC providers for IRSA"
  type        = map(object({
    provider_arn               = string
    namespace_service_accounts = list(string)
  }))
  default     = {}
}

/*variable "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  type        = string
}*/

variable "velero_environment" {
  description = "Environment name used for the Velero backup bucket"
  type        = string
  default     = "production"
}