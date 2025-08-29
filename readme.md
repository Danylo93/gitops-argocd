https://argo-cd.readthedocs.io/en/stable/getting_started/



Senha Argo:

admin
ukAAxld7gRbnXNj3

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo


kubectl port-forward svc/argocd-server -n argocd 8080:443