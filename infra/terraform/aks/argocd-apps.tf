locals {
  eck_operator_app = templatefile(
    "${path.module}/manifests/argocd/eck-operator.yaml.tpl",
    {
      repo_url        = var.argocd_app_repo_url
      target_revision = var.argocd_app_target_revision
    }
  )

  eck_stack_app = templatefile(
    "${path.module}/manifests/argocd/eck-stack.yaml.tpl",
    {
      repo_url        = var.argocd_app_repo_url
      target_revision = var.argocd_app_target_revision
    }
  )
}

resource "kubectl_manifest" "eck_operator_app" {
  provider  = kubectl.argocd
  yaml_body = local.eck_operator_app
  wait      = true
  depends_on = [
    helm_release.argo_cd_repo,
    helm_release.argo_cd_oci,
  ]
}

resource "kubectl_manifest" "eck_stack_app" {
  provider  = kubectl.argocd
  yaml_body = local.eck_stack_app
  wait      = true
  depends_on = [kubectl_manifest.eck_operator_app]
}
