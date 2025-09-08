Provisionar ECK e Strimzi via IaC (Terraform + ArgoCD)

- O Terraform aplica os Applications do ArgoCD:
  - Operator/CRDs: path `k8s/eck/operator`
  - Stack (Elasticsearch + Kibana): path `k8s/eck/stack`
  - Strimzi Operator: path `k8s/strimzi`
  - Cluster Kafka: path `k8s/strimzi/kafka`

Uso

- Se você já tem ArgoCD rodando e só quer aplicar ECK e Strimzi:
  - `cd infra/terraform/apps`
  - Garanta que o `KUBECONFIG` aponta para o cluster correto (ou passe `-var kubeconfig_path="/caminho/kubeconfig"`)
  - `terraform init`
  - `terraform apply -var argocd_app_repo_url="https://github.com/Danylo93/agencia-infra-aks.git" -var argocd_app_target_revision="main"`

  - `terraform apply -var prefix="agencia-infra" -var location="eastus" -var argocd_app_repo_url="https://github.com/Danylo93/agencia-infra-aks.git" -var argocd_app_target_revision="main"`
- `kubectl -n strimzi-system get pods` (Strimzi Operator)
- `kubectl -n kafka get pods,svc` (Kafka)
Observaes
- Elasticsearch: `kubectl -n elastic port-forward svc/es-quickstart-es-http 9200:9200`
- Kibana: `kubectl -n elastic port-forward svc/kibana-kb-http 5601:5601`

Observações

- O Operator usa CRDs e manifests oficiais da Elastic referenciados no repo (Kustomize).
- Ajuste as versÃµes em `k8s/eck/operator/kustomization.yaml` e `k8s/eck/stack/*` conforme necessÃ¡rio.


terraform init
terraform apply -var argocd_app_repo_url="https://github.com/Danylo93/gitops-argocd.git" -var argocd_app_target_revision="main"



kubectl -n argocd get applications.argoproj.io eck-operator eck-stack

kubectl -n elastic port-forward svc/es-quickstart-es-http 9200:9200
kubectl -n elastic port-forward svc/kibana-kb-http 5601:5601
