locals {
  eck_operator_app = templatefile(
    "${path.module}/templates/eck-operator.yaml.tpl",
    {
      repo_url         = var.argocd_app_repo_url
      target_revision  = var.argocd_app_target_revision
      argocd_namespace = var.argocd_namespace
    }
  )

  eck_stack_app = templatefile(
    "${path.module}/templates/eck-stack.yaml.tpl",
    {
      repo_url         = var.argocd_app_repo_url
      target_revision  = var.argocd_app_target_revision
      argocd_namespace = var.argocd_namespace
    }
  )
}

resource "kubectl_manifest" "eck_operator_app" {
  yaml_body = local.eck_operator_app
  wait      = true
}

resource "kubectl_manifest" "eck_stack_app" {
  yaml_body = local.eck_stack_app
  wait      = true
  depends_on = [kubectl_manifest.eck_operator_app]
}

