Provisionar ECK via IaC (Terraform + ArgoCD)

- O Terraform aplica dois Applications do ArgoCD:
  - Operator/CRDs: path `k8s/eck/operator`
  - Stack (Elasticsearch + Kibana): path `k8s/eck/stack`

Uso

- Se você já tem ArgoCD rodando e só quer aplicar o ECK:
  - `cd infra/terraform/eck-apps`
  - Garanta que o `KUBECONFIG` aponta para o cluster correto (ou passe `-var kubeconfig_path="/caminho/kubeconfig"`)
  - `terraform init`
  - `terraform apply -var argocd_app_repo_url="https://github.com/Danylo93/gitops-argocd.git" -var argocd_app_target_revision="main"`

- Para provisionar tudo (AKS + ArgoCD + ECK) pelo módulo AKS:
  - `cd infra/terraform/aks`
  - `terraform apply -var prefix="myorg" -var location="eastus" -var argocd_app_repo_url="https://github.com/Danylo93/gitops-argocd.git" -var argocd_app_target_revision="main"`

Verificação

- `kubectl -n argocd get applications.argoproj.io eck-operator eck-stack`
- `kubectl -n elastic-system get pods` (operator)
- `kubectl -n elastic get elasticsearch,kibana,pods,svc`

Acesso rápido

- Elasticsearch: `kubectl -n elastic port-forward svc/es-quickstart-es-http 9200:9200`
- Kibana: `kubectl -n elastic port-forward svc/kibana-kb-http 5601:5601`

Observações

- O Operator usa CRDs e manifests oficiais da Elastic referenciados no repo (Kustomize).
- Ajuste as versões em `k8s/eck/operator/kustomization.yaml` e `k8s/eck/stack/*` conforme necessário.


terraform init
terraform apply -var argocd_app_repo_url="https://github.com/Danylo93/gitops-argocd.git" -var argocd_app_target_revision="main"



kubectl -n argocd get applications.argoproj.io eck-operator eck-stack