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

  strimzi_operator_app = templatefile(
    "${path.module}/templates/strimzi-operator.yaml.tpl",
    {
      repo_url         = var.argocd_app_repo_url
      target_revision  = var.argocd_app_target_revision
      argocd_namespace = var.argocd_namespace
      strimzi_namespace = var.strimzi_namespace
      kafka_namespace  = var.kafka_namespace
      strimzi_chart_version = var.strimzi_chart_version
    }
  )

  strimzi_kafka_app = templatefile(
    "${path.module}/templates/strimzi-kafka.yaml.tpl",
    {
      repo_url         = var.argocd_app_repo_url
      target_revision  = var.argocd_app_target_revision
      argocd_namespace = var.argocd_namespace
      kafka_namespace  = var.kafka_namespace
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

resource "kubectl_manifest" "strimzi_operator_app" {
  yaml_body = local.strimzi_operator_app
  wait      = true
}

resource "kubectl_manifest" "strimzi_kafka_app" {
  yaml_body = local.strimzi_kafka_app
  wait      = true
  depends_on = [kubectl_manifest.strimzi_operator_app]
}
