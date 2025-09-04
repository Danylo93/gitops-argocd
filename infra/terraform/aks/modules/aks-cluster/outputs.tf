output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource Group name"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS cluster name"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config
  description = "Kube config object (sensitive)"
  sensitive   = true
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  description = "Raw kubeconfig (sensitive)"
  sensitive   = true
}

output "kube_host" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  description = "API server host"
  sensitive   = true
}

output "kube_client_certificate" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  description = "Base64 client certificate"
  sensitive   = true
}

output "kube_client_key" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  description = "Base64 client key"
  sensitive   = true
}

output "kube_cluster_ca_certificate" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  description = "Base64 cluster CA"
  sensitive   = true
}

