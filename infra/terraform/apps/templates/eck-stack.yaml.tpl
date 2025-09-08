apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: eck-stack
  namespace: ${argocd_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: elastic
  source:
    repoURL: ${repo_url}
    targetRevision: ${target_revision}
    path: k8s/eck/stack
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

