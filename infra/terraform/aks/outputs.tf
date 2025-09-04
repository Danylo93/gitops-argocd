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

