Infra AKS + ArgoCD (Terraform)

- Pré-requisitos: `az login`, `terraform >= 1.4`, permissões na subscription.
- Deploy AKS (ArgoCD):
  - `cd infra/terraform/aks`
  - `terraform init`
  - `terraform apply -var prefix="myorg" -var location="eastus"`
- Kubeconfig do cluster ArgoCD:
  - `terraform output -raw argocd_kubeconfig > kubeconfig_argocd`
  - Linux/macOS: `export KUBECONFIG=$PWD/kubeconfig_argocd`
  - PowerShell: `$env:KUBECONFIG=(Get-Location).Path+"\kubeconfig_argocd"`
- Acesso ArgoCD:
  - Namespace: `argocd`
  - Senha inicial: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`
  - Port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Segundo cluster opcional p/ Rancher: adicione `-var create_rancher_cluster=true` no apply.

Referências: https://argo-cd.readthedocs.io/en/stable/getting_started/


# Acesso Local (Port-forward)

- ArgoCD:
  - `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`
  - `kubectl -n argocd port-forward svc/argocd-server 8080:443`
  - Abrir `https://localhost:8080` (usuário: `admin`)

- Rancher (após instalar via Helm):
  - `kubectl -n cattle-system port-forward svc/rancher 8443:443`
  - Abrir `https://localhost:8443` (usuário inicial: `admin`)
  - Senha bootstrap: `kubectl -n cattle-system get secret bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'`


# Instalar Rancher via Helm (opcional)

1) Adicionar repositórios e preparar namespace:
   - `helm repo add rancher-latest https://releases.rancher.com/server-charts/latest`
   - `helm repo add jetstack https://charts.jetstack.io`
   - `helm repo update`
   - `kubectl create namespace cattle-system`

2) Instalar cert-manager (pré-requisito):
   - `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml`
   - `helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.14.4`

3) Instalar Rancher (TLS próprio e hostname local):
   - `helm install rancher rancher-latest/rancher \
       --namespace cattle-system \
       --set hostname=127.0.0.1.sslip.io \
       --set ingress.tls.source=rancher \
       --set replicas=1`

4) Acessar localmente com port-forward:
   - `kubectl -n cattle-system port-forward svc/rancher 8443:443`
   - Abrir `https://localhost:8443`


# Se o Helm não consegue baixar o chart (proxy/rede)

- Opção A: usar o chart via OCI (ex.: Bitnami):
  - `terraform apply -var prefix="myorg" -var location="eastus" \
      -var install_argocd=true \
      -var argocd_chart_is_oci=true \
      -var argocd_chart="oci://registry-1.docker.io/bitnamicharts/argo-cd" \
      -var argocd_chart_version="<versão>"`

- Opção B: desabilitar o Helm no Terraform e instalar via kubectl (manifesto oficial):
  - `terraform apply -var prefix="myorg" -var location="eastus" -var install_argocd=false`
  - `kubectl create namespace argocd`
  - `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

- Dica de proxy:
  - Linux/WSL: `export HTTPS_PROXY=http://<host>:<port>` e `export HTTP_PROXY=http://<host>:<port>` antes do `terraform apply`
  - PowerShell: `$env:HTTPS_PROXY="http://<host>:<port>"; $env:HTTP_PROXY="http://<host>:<port>"`


# Notas

- Evite manter senhas no repositório. Use `kubectl` para obter senhas iniciais conforme acima.


