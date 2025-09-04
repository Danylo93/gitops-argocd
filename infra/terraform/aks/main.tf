module "argocd" {
  source             = "./modules/aks-cluster"
  name               = "argocd"
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.argocd_node_count
  vm_size            = var.argocd_vm_size
  tags = {
    "managed-by" = "terraform"
    "stack"      = "argocd"
  }
}

module "rancher" {
  source             = "./modules/aks-cluster"
  count              = var.create_rancher_cluster ? 1 : 0
  name               = "rancher"
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.rancher_node_count
  vm_size            = var.rancher_vm_size
  tags = {
    "managed-by" = "terraform"
    "stack"      = "rancher"
  }
}

provider "helm" {
  alias      = "argocd"
  kubernetes = {
    host                   = module.argocd.kube_host
    client_certificate     = base64decode(module.argocd.kube_client_certificate)
    client_key             = base64decode(module.argocd.kube_client_key)
    cluster_ca_certificate = base64decode(module.argocd.kube_cluster_ca_certificate)
  }
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  repository_cache       = "${path.module}/.helm/cache"
}

provider "kubectl" {
  alias                  = "argocd"
  host                   = module.argocd.kube_host
  client_certificate     = base64decode(module.argocd.kube_client_certificate)
  client_key             = base64decode(module.argocd.kube_client_key)
  cluster_ca_certificate = base64decode(module.argocd.kube_cluster_ca_certificate)
  load_config_file       = false
}

resource "helm_release" "argo_cd_repo" {
  count             = var.install_argocd && !var.argocd_chart_is_oci ? 1 : 0
  provider          = helm.argocd
  name              = "argo-cd"
  repository        = var.argocd_repo_url
  chart             = var.argocd_chart
  version           = var.argocd_chart_version
  namespace         = "argocd"
  create_namespace  = true
  dependency_update = true
  timeout           = 600
}

resource "helm_release" "argo_cd_oci" {
  count             = var.install_argocd && var.argocd_chart_is_oci ? 1 : 0
  provider          = helm.argocd
  name              = "argo-cd"
  chart             = var.argocd_chart
  version           = var.argocd_chart_version
  namespace         = "argocd"
  create_namespace  = true
  dependency_update = true
  timeout           = 600
}
