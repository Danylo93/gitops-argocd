terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

provider "kubectl" {
  load_config_file = true
  config_path      = coalesce(var.kubeconfig_path, "~/.kube/config")
}

