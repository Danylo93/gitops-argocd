Guia do Repositório

- docs/aks.md — Provisionamento AKS + ArgoCD (Terraform)
- docs/eck-iac.md — ECK (Operator + Stack) via ArgoCD (Terraform)
- docs/apps-gitops.md — Como adicionar apps (Kustomize + ArgoCD)

Acesso Local (atalhos)

- ArgoCD
  - Senha inicial: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`
  - URL (DNS): https://argocd.quantum-flow.tech (usuário: admin)
  - (alternativa local) Port-forward: `kubectl -n argocd port-forward svc/argocd-server 8080:443` => https://localhost:8080

- Rancher (se instalado)
  - URL (DNS): https://rancher.quantum-flow.tech
  - (alternativa local) Port-forward: `kubectl -n cattle-system port-forward svc/rancher 8443:443` => https://localhost:8443
  - Senha bootstrap: `kubectl -n cattle-system get secret bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'`

Instalar Rancher via Helm (opcional)

1) Repositórios e namespace
   - `helm repo add rancher-latest https://releases.rancher.com/server-charts/latest`
   - `helm repo add jetstack https://charts.jetstack.io`
   - `helm repo update`
   - `kubectl create namespace cattle-system`

2) cert-manager (pré-requisito)
   - `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml`
   - `helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.14.4`

3) Rancher (TLS próprio + hostname local)
   - `helm install rancher rancher-latest/rancher \
       --namespace cattle-system \
       --set hostname=127.0.0.1.sslip.io \
       --set ingress.tls.source=rancher \
       --set replicas=1`

4) Acesso
   - `kubectl -n cattle-system port-forward svc/rancher 8443:443`
   - URL: https://localhost:8443

Rede/Proxy (Helm no Terraform)

- Opção A (OCI Bitnami):
  - `-var argocd_chart_is_oci=true -var argocd_chart="oci://registry-1.docker.io/bitnamicharts/argo-cd" -var argocd_chart_version="<versão>"`
- Opção B (manifesto):
  - `-var install_argocd=false` e aplicar `install.yaml` oficial com kubectl
- Exporte proxy: `HTTPS_PROXY`/`HTTP_PROXY` (Linux/WSL) ou `$env:HTTPS_PROXY`/`$env:HTTP_PROXY` (PowerShell)

Notas

- Evite manter senhas em arquivos; sempre recupere via `kubectl` conforme exemplos.
- Modo free tier: veja `docs/aks.md` para comandos prontos (gestão, +1 ambiente, +4 ambientes com 1 nó cada) e dicas de quota.
