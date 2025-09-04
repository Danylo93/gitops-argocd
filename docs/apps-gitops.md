Onboarding de Apps (Kustomize + ArgoCD)

Estrutura recomendada

- `k8s/base` → manifests base (Deployment/Service/etc.)
- `k8s/overlays/{dev,hmg,prd}` → customizações por ambiente (patches, replicas, recursos)

Exemplo de Application por overlay

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: meuapp-dev
  namespace: argocd
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: meuapp-dev
  source:
    repoURL: https://github.com/<org>/<repo>.git
    targetRevision: main
    path: k8s/overlays/dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

Dicas

- Para múltiplos apps, use ApplicationSet (por pasta/cluster).
- Padrão de imagens: defina `image:tag` via `kustomize edit set image` ou patches por overlay.
- CI/CD: gere tags imutáveis e crie PRs atualizando o `kustomization.yaml` do overlay.

