output "argocd_resource_group" {
  value       = module.argocd.resource_group_name
  description = "Resource group for ArgoCD AKS"
}

output "argocd_cluster_name" {
  value       = module.argocd.cluster_name
  description = "ArgoCD AKS name"
}

output "argocd_kubeconfig" {
  value       = module.argocd.kube_config_raw
  description = "Raw kubeconfig for ArgoCD cluster"
  sensitive   = true
}

output "rancher_resource_group" {
  value       = try(module.rancher[0].resource_group_name, null)
  description = "Resource group for Rancher AKS (if created)"
}

output "rancher_cluster_name" {
  value       = try(module.rancher[0].cluster_name, null)
  description = "Rancher AKS name (if created)"
}

output "rancher_kubeconfig" {
  value       = try(module.rancher[0].kube_config_raw, null)
  description = "Raw kubeconfig for Rancher cluster (if created)"
  sensitive   = true
}

data "kubernetes_service" "ingress_nginx_controller" {
  count    = var.enable_ingress_ip_output ? 1 : 0
  provider = kubernetes.argocd
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

output "ingress_public_ip" {
  description = "Public IP do ingress-nginx no cluster de gestão (argocd)"
  value       = try(data.kubernetes_service.ingress_nginx_controller[0].status[0].load_balancer[0].ingress[0].ip, null)
}

# Kubeconfigs dos clusters de ambientes (Hub/Dev/HMG/PRD)
output "hub_cluster_name" {
  value       = try(module.hub[0].cluster_name, null)
  description = "Nome do cluster Hub (Wakanda)"
}

output "hub_kubeconfig" {
  value       = try(module.hub[0].kube_config_raw, null)
  description = "Kubeconfig do cluster Hub (Wakanda)"
  sensitive   = true
}

output "dev_cluster_name" {
  value       = try(module.dev[0].cluster_name, null)
  description = "Nome do cluster Dev (Gondor)"
}

output "dev_kubeconfig" {
  value       = try(module.dev[0].kube_config_raw, null)
  description = "Kubeconfig do cluster Dev (Gondor)"
  sensitive   = true
}

output "hmg_cluster_name" {
  value       = try(module.hmg[0].cluster_name, null)
  description = "Nome do cluster HMG (Sokovia)"
}

output "hmg_kubeconfig" {
  value       = try(module.hmg[0].kube_config_raw, null)
  description = "Kubeconfig do cluster HMG (Sokovia)"
  sensitive   = true
}

output "prd_cluster_name" {
  value       = try(module.prd[0].cluster_name, null)
  description = "Nome do cluster PRD (Argard)"
}

output "prd_kubeconfig" {
  value       = try(module.prd[0].kube_config_raw, null)
  description = "Kubeconfig do cluster PRD (Argard)"
  sensitive   = true
}
