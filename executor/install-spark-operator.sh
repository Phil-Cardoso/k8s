helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm repo update

helm install spark-operator spark-operator/spark-operator \
  --namespace executor \
  --create-namespace \
  --set sparkJobNamespace=executor \
  --set webhook.enable=true \
  --set serviceAccounts.spark.name=spark \
  --set enableBatchScheduler=true \
  --set batchScheduler.enable=true \
  --wait

kubectl create clusterrolebinding spark-cleanup \
  --clusterrole=edit \
  --serviceaccount=executor:spark

kubectl apply -f spark-operator-rolebinding.yaml
kubectl apply -f spark-cleanup-rolebinding.yaml
kubectl apply -f spark-cleanup-role.yaml
kubectl apply -f RoleBinding.yaml
kubectl apply -f role.yaml