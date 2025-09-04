variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "kubernetes_version" {
  description = "Optional AKS version (e.g., 1.29.2). Leave null for default"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Azure subscription ID (optional if using az CLI context)"
  type        = string
  default     = null
}

variable "argocd_node_count" {
  description = "Node count for ArgoCD cluster"
  type        = number
  default     = 2
}

variable "argocd_vm_size" {
  description = "VM size for ArgoCD cluster node pool"
  type        = string
  default     = "standard_a2_v2"
}

variable "install_argocd" {
  description = "Install ArgoCD via Helm"
  type        = bool
  default     = true
}

variable "argocd_repo_url" {
  description = "Helm repository URL for ArgoCD (ignored if using OCI)"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_chart" {
  description = "Chart name (e.g., argo-cd) or OCI ref (e.g., oci://.../argo-cd)"
  type        = string
  default     = "argo-cd"
}

variable "argocd_chart_version" {
  description = "Chart version (optional; recommended in CI)"
  type        = string
  default     = null
}

variable "argocd_chart_is_oci" {
  description = "Treat argocd_chart as an OCI reference"
  type        = bool
  default     = false
}

variable "create_rancher_cluster" {
  description = "Also create a second AKS cluster for Rancher"
  type        = bool
  default     = false
}

variable "rancher_node_count" {
  description = "Node count for Rancher cluster"
  type        = number
  default     = 2
}

variable "rancher_vm_size" {
  description = "VM size for Rancher cluster node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "argocd_app_repo_url" {
  description = "Git repo URL usado pelos Applications do ArgoCD"
  type        = string
  default     = "https://github.com/OWNER/REPO.git"
}

variable "argocd_app_target_revision" {
  description = "Branch, tag ou commit para os Applications do ArgoCD"
  type        = string
  default     = "main"
}
