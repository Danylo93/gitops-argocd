resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.name}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-${var.name}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-${var.name}"
  kubernetes_version  = var.kubernetes_version

  role_based_access_control_enabled = true

  default_node_pool {
    name                = "systempool"
    vm_size             = var.vm_size
    node_count          = var.node_count
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "kafka" {
  count                 = var.create_kafka_node_pool ? 1 : 0
  name                  = var.kafka_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.kafka_vm_size
  node_count            = var.kafka_node_count
  mode                  = "User"
  orchestrator_version  = var.kubernetes_version
  node_labels           = var.kafka_node_labels
  node_taints           = var.kafka_node_taints
  tags                  = var.tags
}
