module "argocd" {
  source             = "./modules/aks-cluster"
  name               = "argocd"
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.argocd_node_count
  vm_size            = var.argocd_vm_size
  create_kafka_node_pool = var.create_kafka_node_pool
  kafka_node_pool_name   = var.kafka_node_pool_name
  kafka_node_count       = var.kafka_node_count
  kafka_vm_size          = var.kafka_vm_size
  kafka_node_labels      = var.kafka_node_labels
  kafka_node_taints      = var.kafka_node_taints
  tags = {
    "managed-by" = "terraform"
    "stack"      = "argocd"
    "role"       = "mgmt"
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

  # Enable ingress for ArgoCD server with cert-manager TLS
  values = [
    yamlencode({
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hostname         = var.argocd_hostname
          tls              = true
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt"
          }
        }
      }
    })
  ]
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

  # Enable ingress for ArgoCD server with cert-manager TLS
  values = [
    yamlencode({
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hostname         = var.argocd_hostname
          tls              = true
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt"
          }
        }
      }
    })
  ]
}

# Ingress Controller (NGINX) on management cluster
resource "helm_release" "ingress_nginx" {
  count           = var.install_k8s_addons ? 1 : 0
  provider         = helm.argocd
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_chart_version
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 600

  # For AKS, defaults are generally fine; using LoadBalancer service
}

# cert-manager on management cluster (installs CRDs via Helm)
resource "helm_release" "cert_manager" {
  count            = var.install_k8s_addons ? 1 : 0
  provider         = helm.argocd
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = "cert-manager"
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
}

# ClusterIssuer for Let's Encrypt (HTTP-01 via NGINX)
resource "kubectl_manifest" "clusterissuer_letsencrypt" {
  count     = var.install_k8s_addons ? 1 : 0
  provider  = kubectl.argocd
  wait      = true
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: ${var.letsencrypt_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          ingress:
            class: nginx
YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx,
  ]
}

# Rancher on management cluster (optional)
resource "helm_release" "rancher" {
  count            = var.install_rancher ? 1 : 0
  provider         = helm.argocd
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  version          = var.rancher_chart_version
  namespace        = "cattle-system"
  create_namespace = true
  timeout          = 1200

  values = [
    yamlencode({
      hostname = var.rancher_hostname
      ingress = {
        ingressClassName = "nginx"
        tls = {
          source = "letsEncrypt"
        }
      }
      letsEncrypt = {
        email = var.letsencrypt_email
        ingress = {
          class = "nginx"
        }
      }
    })
  ]

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.cert_manager,
  ]
}

# Hub/Spoke clusters (infra only; no apps installed by default)
module "hub" {
  source             = "./modules/aks-cluster"
  count              = var.create_env_clusters && var.enable_hub ? 1 : 0
  name               = var.hub_name
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.env_node_count
  vm_size            = var.env_vm_size
  tags = {
    "managed-by" = "terraform"
    "env"        = "hub"
    "name"       = var.hub_name
    "arch"       = "hub-spoke"
  }
}

module "dev" {
  source             = "./modules/aks-cluster"
  count              = var.create_env_clusters && var.enable_dev ? 1 : 0
  name               = var.dev_name
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.env_node_count
  vm_size            = var.env_vm_size
  tags = {
    "managed-by" = "terraform"
    "env"        = "dev"
    "name"       = var.dev_name
    "arch"       = "hub-spoke"
  }
}

module "hmg" {
  source             = "./modules/aks-cluster"
  count              = var.create_env_clusters && var.enable_hmg ? 1 : 0
  name               = var.hmg_name
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.env_node_count
  vm_size            = var.env_vm_size
  tags = {
    "managed-by" = "terraform"
    "env"        = "hmg"
    "name"       = var.hmg_name
    "arch"       = "hub-spoke"
  }
}

module "prd" {
  source             = "./modules/aks-cluster"
  count              = var.create_env_clusters && var.enable_prd ? 1 : 0
  name               = var.prd_name
  prefix             = var.prefix
  location           = var.location
  kubernetes_version = var.kubernetes_version
  node_count         = var.env_node_count
  vm_size            = var.env_vm_size
  tags = {
    "managed-by" = "terraform"
    "env"        = "prd"
    "name"       = var.prd_name
    "arch"       = "hub-spoke"
  }
}
