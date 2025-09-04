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

variable "create_kafka_node_pool" {
  description = "Create dedicated node pool for Kafka"
  type        = bool
  default     = false
}

variable "kafka_node_pool_name" {
  description = "Name of the Kafka node pool"
  type        = string
  default     = "kafka"
}

variable "kafka_node_count" {
  description = "Node count for Kafka node pool"
  type        = number
  default     = 2
}

variable "kafka_vm_size" {
  description = "VM size for Kafka node pool"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "kafka_node_labels" {
  description = "Node labels for Kafka node pool"
  type        = map(string)
  default     = { workload = "kafka" }
}

variable "kafka_node_taints" {
  description = "Node taints for Kafka node pool"
  type        = list(string)
  default     = ["workload=kafka:NoSchedule"]
}
