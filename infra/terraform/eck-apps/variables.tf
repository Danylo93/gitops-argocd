variable "kubeconfig_path" {
  description = "Path do kubeconfig (deixe vazio para usar ~/.kube/config ou $KUBECONFIG)"
  type        = string
  default     = null
}

variable "argocd_namespace" {
  description = "Namespace onde o ArgoCD está instalado"
  type        = string
  default     = "argocd"
}

variable "argocd_app_repo_url" {
  description = "URL do repositório Git com os manifests (este repo)"
  type        = string
}

variable "argocd_app_target_revision" {
  description = "Branch/Tag/Commit para os Applications do ArgoCD"
  type        = string
  default     = "main"
}

variable "strimzi_namespace" {
  description = "Namespace onde o Strimzi Operator será instalado"
  type        = string
  default     = "strimzi-system"
}

variable "kafka_namespace" {
  description = "Namespace do cluster Kafka (CR)"
  type        = string
  default     = "kafka"
}

variable "strimzi_chart_version" {
  description = "Versão do chart Helm do Strimzi Operator"
  type        = string
  default     = "0.41.0"
}
