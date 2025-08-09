helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update

helm install spark-operator spark-operator/spark-operator \
  --namespace executor \
  --create-namespace \
  --set sparkJobNamespace=executor \
  --set webhook.enable=true \
  --set serviceAccounts.spark.name=spark \
  --set enableBatchScheduler=true \
  --set batchScheduler.enable=true