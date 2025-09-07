AKS + ArgoCD (Terraform)

- Requisitos:
  - Azure CLI autenticado: `az login` e `az account set --subscription <SUB_ID>`
  - Terraform >= 1.4

Provisionar

- `cd infra/terraform/aks`
- `terraform init`
- Free tier (padrão ajustado): `terraform apply -var prefix="myorg" -var location="eastus"`
- Kubeconfig: `terraform output -raw argocd_kubeconfig > kubeconfig_argocd`
  - Linux/macOS: `export KUBECONFIG=$PWD/kubeconfig_argocd`
  - PowerShell: `$env:KUBECONFIG=(Get-Location).Path+"\kubeconfig_argocd"`

ArgoCD via Helm (padrão)

- Se houver bloqueio de rede/timeout no repo do Argo, use OCI Bitnami ou manifeste oficial:
  - Usar OCI (Bitnami):
    - `-var argocd_chart_is_oci=true -var argocd_chart="oci://registry-1.docker.io/bitnamicharts/argo-cd" -var argocd_chart_version="<versão>"`
  - Ou desabilitar Helm e aplicar manifesto oficial:
    - `-var install_argocd=false` e depois `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

Rancher (opcional)

- Criar segundo cluster: `-var create_rancher_cluster=true`
- Instalar Rancher (manual): ver seção no `readme.md` (Helm + cert-manager), depois port-forward `8443:443`.

DNS público (ArgoCD + Rancher)

- Pré-requisito: o domínio real (ex.: `quantum-flow.tech`, hospedado na Contabo) deve apontar para o IP público do Ingress (AKS).
- Passos após o `terraform apply`:
  - Obtenha o IP: `terraform output ingress_public_ip`
  - Crie registros DNS na Contabo:
    - `A argocd.quantum-flow.tech -> <IP>`
    - `A rancher.quantum-flow.tech -> <IP>`
  - Aguarde a propagação DNS (geralmente alguns minutos).
  - Acesse:
    - ArgoCD: `https://argocd.quantum-flow.tech` (usuário `admin`, senha inicial via secret)
    - Rancher: `https://rancher.quantum-flow.tech`

TLS/Let's Encrypt

- Certificados são emitidos automaticamente via cert-manager (HTTP-01) usando o `ClusterIssuer` `letsencrypt` e o Ingress NGINX.
- Variável obrigatória: `-var letsencrypt_email="seu-email@dominio.com"`.

Hub/Spoke (Múltiplos clusters)

- Este repositório cria 4 clusters opcionais no padrão Hub/Spoke (apenas Dev/Gondor habilitado por enquanto):
  - Hub: `wakanda`, Dev: `gondor`, HMG: `sokovia`, PRD: `asgard`.
- Free tier: desabilitado por padrão. Crie/ligue apenas 1 ambiente por vez.
- Observação: a topologia de rede (VNets/peering/firewall) não está incluída aqui. Caso precise de Hub/Spoke de rede Azure completo, criar os VNets e peerings via Terraform de rede e apontar os AKS para sub-redes específicas.

Importar clusters no Rancher

- Gere os kubeconfigs (sensíveis). Se os outputs estiverem nulos, use az CLI:
  - `az aks get-credentials -g myorg-wakanda-rg -n myorg-wakanda-aks --admin --file kubeconfig_hub --overwrite-existing`
  - `az aks get-credentials -g myorg-gondor-rg  -n myorg-gondor-aks  --admin --file kubeconfig_dev --overwrite-existing`
  - `az aks get-credentials -g myorg-sokovia-rg -n myorg-sokovia-aks --admin --file kubeconfig_hmg --overwrite-existing`
  - `az aks get-credentials -g myorg-asgard-rg  -n myorg-asgard-aks  --admin --file kubeconfig_prd --overwrite-existing`
- No Rancher UI: Clusters > Create > Import Existing, crie os 4 (Wakanda/Gondor/Sokovia/Asgard) e copie o comando `kubectl apply -f https://...` gerado para cada um.
- Em 4 terminais (ou sequencialmente):
  - `KUBECONFIG=$PWD/kubeconfig_hub kubectl apply -f <manifest_url_do_Wakanda>`
  - `KUBECONFIG=$PWD/kubeconfig_dev kubectl apply -f <manifest_url_do_Gondor>`
  - `KUBECONFIG=$PWD/kubeconfig_hmg kubectl apply -f <manifest_url_do_Sokovia>`
  - `KUBECONFIG=$PWD/kubeconfig_prd kubectl apply -f <manifest_url_do_Asgard>`
- Volte ao Rancher UI e aguarde ficarem Active. Se o acesso externo não estiver pronto, use port-forward para o Rancher conforme readme.

Proxy

- Linux/WSL: `export HTTPS_PROXY=...; export HTTP_PROXY=...`
- PowerShell: `$env:HTTPS_PROXY="..."; $env:HTTP_PROXY="..."`


Free tier: dicas rápidas

- Limite de vCPU típico: 10 vCPU na região. B2s usa 2 vCPU por nó.
- Mantenha 1 nó no cluster de gestão e ative só 1 ambiente por vez.
- Você pode parar clusters para liberar vCPU: `az aks stop -g <rg> -n <aks>` e `az aks start -g <rg> -n <aks>`.
Comandos prontos (free tier)

- Somente gestão (Argocd/Rancher via port-forward):
  - `terraform apply -var prefix="myorg" -var location="eastus"`

- Gestão + 1 ambiente (ex.: Hub/Wakanda):
  - `terraform apply -var prefix="myorg" -var location="eastus" \
     -var create_env_clusters=true -var enable_hub=true -var enable_dev=false -var enable_hmg=false -var enable_prd=false \
     -var argocd_node_count=1 -var env_node_count=1 -var argocd_vm_size=Standard_B2s -var env_vm_size=Standard_B2s`

- Gestão + todos os 4 ambientes (1 nó cada):
  - `terraform apply -var prefix="myorg" -var location="eastus" \
     -var create_env_clusters=true -var enable_hub=true -var enable_dev=true -var enable_hmg=true -var enable_prd=true \
     -var argocd_node_count=1 -var env_node_count=1 -var argocd_vm_size=Standard_B2s -var env_vm_size=Standard_B2s`

- Dicas de quota (10 vCPU):
  - B2s = 2 vCPU por nó. Evite passar de 5 nós totais.
  - Para liberar vCPU temporariamente: `az aks stop -g <rg> -n <aks>` e `az aks start -g <rg> -n <aks>`.



curl -k -u "token-z55c5:lxh2cklvs4b2sq4ms4lbrm4qqs5rbf929c7hfqnmhdkggzksqcsbsn" -X DELETE "https://rancher.quantum-flow.tech/v3/clusters/asgard"