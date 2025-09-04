apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: strimzi-operator
  namespace: ${argocd_namespace}
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: ${strimzi_namespace}
  source:
    repoURL: https://strimzi.io/charts/
    chart: strimzi-kafka-operator
    targetRevision: ${strimzi_chart_version}
    helm:
      parameters:
        - name: watchNamespaces
          value: ${kafka_namespace}
        - name: createGlobalResources
          value: "true"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

