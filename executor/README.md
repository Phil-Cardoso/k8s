# Executor - Instalação do Spark Operator

Este script tem como objetivo realizar a instalação do Spark Operator no cluster Kubernetes local, utilizando o Helm como gerenciador de pacotes.

O Spark Operator será responsável por permitir a execução de jobs Spark no cluster Kubernetes, tornando possível o processamento distribuído de dados diretamente no ambiente orquestrado pelo Minikube.

## Descrição do Script

O script `install-spark-operator.sh`presente nesta pasta executa os seguintes passos:

1. Adiciona o repositório Helm do Spark Operator:
```bash
helm repo add spark-operator https://kubeflow.github.io/spark-operator
```
Caso queira, você pode visitar a [página oficial do projeto](https://kubeflow.github.io/spark-operator) para mais informações.

2. Atualiza a lista de charts disponíveis:
```bash
helm repo update
```

3. Instala o Spark Operator no namespace executor:
```bash
helm install spark-operator spark-operator/spark-operator \
  --namespace executor \
  --create-namespace \
  --set sparkJobNamespace=executor \
  --set webhook.enable=true \
  --set serviceAccounts.spark.name=spark \
  --set enableBatchScheduler=true \
  --set batchScheduler.enable=true
```

## Namespace `executor`
Todos os recursos criados serão organizados no namespace executor, que representa o ambiente responsável pela execução de pipelines e scripts ETL usando Spark.

Caso o namespace ainda não exista, crie-o utilizando os comandos indicados no **README** localizado na raiz deste repositório.

## Como Executar o Script

1. Certifique-se de que o Minikube esteja ativo e o cluster em execução:
```bash
minikube status
```

2. Certifique-se de que o contexto do `kubectl` está apontando para o Minikube:
```bash
kubectl config use-context minikube
```

3. Certifique-se que o namespace **executor** existe
```bash
kubectl get namespaces
```

4. Dê permissão de execução ao arquivo `.sh`:
```bash
chmod +x install-spark-operator.sh
```

5. Execute o script:
```bash
./install-spark-operator.sh
```

6. Verifique se a instalação foi realizada com sucesso:
```bash
kubectl get pods -n executor
```

## Resultado Esperado
Após a execução, o Spark Operator estará disponível no namespace `executor`, pronto para gerenciar e executar aplicações Spark no seu cluster Kubernetes local.