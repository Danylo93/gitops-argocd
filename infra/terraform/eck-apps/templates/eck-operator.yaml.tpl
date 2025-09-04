apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: eck-operator
  namespace: ${argocd_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: elastic-system
  source:
    repoURL: ${repo_url}
    targetRevision: ${target_revision}
    path: k8s/eck/operator
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

