apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: postgres
  namespace: ${argocd_namespace}
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: ${postgres_namespace}
  source:
    repoURL: ${repo_url}
    targetRevision: ${target_revision}
    path: k8s/postgres
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
