helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm repo update

helm install spark-operator spark-operator/spark-operator \
  --namespace executor \
  --create-namespace \
  --set sparkJobNamespace=executor \
  --set webhook.enable=true \
  --set serviceAccounts.spark.name=spark \
  --set enableBatchScheduler=true \
  --set batchScheduler.enable=true

kubectl create clusterrolebinding spark-cleanup \
  --clusterrole=edit \
  --serviceaccount=executor:spark