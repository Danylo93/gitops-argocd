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
