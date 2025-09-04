AKS + ArgoCD (Terraform)

- Requisitos:
  - Azure CLI autenticado: `az login` e `az account set --subscription <SUB_ID>`
  - Terraform >= 1.4

Provisionar

- `cd infra/terraform/aks`
- `terraform init`
- `terraform apply -var prefix="myorg" -var location="eastus"`
- Kubeconfig: `terraform output -raw argocd_kubeconfig > kubeconfig_argocd`
  - Linux/macOS: `export KUBECONFIG=$PWD/kubeconfig_argocd`
  - PowerShell: `$env:KUBECONFIG=(Get-Location).Path+"\kubeconfig_argocd"`

ArgoCD via Helm (padrão)

- Por padrão instalamos via Helm. Se houver bloqueio de rede:
  - Usar OCI (Bitnami):
    - `-var argocd_chart_is_oci=true -var argocd_chart="oci://registry-1.docker.io/bitnamicharts/argo-cd" -var argocd_chart_version="<versão>"`
  - Ou desabilitar Helm e aplicar manifesto oficial:
    - `-var install_argocd=false` e depois `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

Rancher (opcional)

- Criar segundo cluster: `-var create_rancher_cluster=true`
- Instalar Rancher (manual): ver seção no `readme.md` (Helm + cert-manager), depois port-forward `8443:443`.

Proxy

- Linux/WSL: `export HTTPS_PROXY=...; export HTTP_PROXY=...`
- PowerShell: `$env:HTTPS_PROXY="..."; $env:HTTP_PROXY="..."`


terraform apply -var prefix="myorg" -var create_kafka_node_pool=true -var kafka_node_count=3 -var kafka_vm_size="standard_a2_v2" -var install_argocd=false