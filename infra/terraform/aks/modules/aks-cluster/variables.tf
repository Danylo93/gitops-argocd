variable "name" {
  description = "Cluster short name (e.g., argocd, rancher)"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "kubernetes_version" {
  description = "Optional AKS version"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Default node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

