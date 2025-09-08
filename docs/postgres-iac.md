Provisionar Postgres via IaC (Terraform + ArgoCD)

- Se você já possui ArgoCD e deseja aplicar apenas o Postgres:
  - `cd infra/terraform/apps`
  - Garanta que o `KUBECONFIG` aponta para o cluster correto (ou passe `-var kubeconfig_path="/caminho/kubeconfig"`)
  - `terraform init`
  - `terraform apply -var argocd_app_repo_url="https://github.com/Danylo93/agencia-infra-aks.git" -var argocd_app_target_revision="main"`

Verificação

- `kubectl -n argocd get applications.argoproj.io postgres`
- `kubectl -n postgres get pods,svc`
