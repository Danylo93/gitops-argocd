apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: strimzi-kafka
  namespace: ${argocd_namespace}
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: ${kafka_namespace}
  source:
    repoURL: ${repo_url}
    targetRevision: ${target_revision}
    path: k8s/strimzi/kafka
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

