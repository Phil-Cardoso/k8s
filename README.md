# K8S

## O que é Kubernetes (k8s)?
Kubernetes, também conhecido como k8s, é uma ferramenta que ajuda a gerenciar aplicações que rodam em contêineres, como os criados com Docker. Ele facilita tarefas como iniciar, parar, escalar (aumentar ou reduzir) e monitorar essas aplicações de forma automática. É muito usado por empresas que precisam manter seus sistemas funcionando de forma estável, mesmo com muitos usuários ou mudanças constantes.

## Definição de Projeto
Este repositório foi criado com o objetivo de apoiar meu aprendizado em k8s no macOS. Estou estudando o assunto e utilizei este espaço para praticar e organizar meus experimentos.

## Pré-requisitos
Antes de iniciar, certifique-se de que os seguintes recursos estejam instalados em sua máquina:

* [Homebrew](https://brew.sh)
* [Docker](https://www.docker.com)
* [Docker-Compose](https://docs.docker.com/compose/)
* [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download)
* [Kubectl](https://kubernetes.io/docs/reference/kubectl/)
* [Helm Charts](https://helm.sh)

## Instalação no macOS
Para instalar os recursos acima no macOS, siga os passos abaixo. Primeiro, instale o Homebrew (caso ainda não tenha):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Com o Homebrew instalado, você pode instalar os demais componentes:

Nota: Após a instalação, abra o aplicativo Docker manualmente para que ele inicie o daemon.

Docker
```bash
brew install --cask docker
```

Docker Compose
```bash
brew install docker-compose
```

Minikube
```bash
brew install minikube
```

kubectl 

O `kubectl` geralmente é instalado junto com o Minikube, mas, se necessário, pode ser instalado separadamente:

```bash
brew install kubectl
```

Helm
```bash
brew install helm
```

## Criando Cluster com Minikube
Para utilizar o Kubernetes (k8s), é necessário ter um cluster em execução, que servirá como ambiente onde nossas aplicações, pods e serviços serão executados. O Minikube é uma ferramenta que facilita a criação de um cluster local para fins de desenvolvimento e testes.

Agora que já temos todos os pré-requisitos instalados, podemos iniciar o cluster com o seguinte comando:
```bash
minikube start --driver=docker
```

Esse comando irá criar um cluster local com uma configuração padrão, pronto para receber recursos do Kubernetes.

Ao final da criação do cluster execute o seguinte comando para ver o status do minikube
```bash
minikube status
```

O retorno esperado é:
```txt
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Em seguida, configure o `kubectl` para utilizar o contexto do Minikube:
```bash
kubectl config use-context minikube
```

Após a criação do cluster e a configuração do `kubectl`, o próximo passo é organizar nossas aplicações. Para isso, vamos criar **namespaces**, que funcionam como ambientes isolados dentro do cluster, permitindo separar e gerenciar melhor os recursos.

Criaremos os seguintes namespaces no cluster, cada um representando uma parte isolada da aplicação:

* executor
* scheduler
* viewer
* storage

### Executor
Este namespace será responsável pela execução dos scripts de ETL. Para isso, será utilizado o `spark-operator`, aproveitando os benefícios de uma ferramenta distribuída, escalável e amplamente adotada no mercado para processamento de dados em larga escala.

### Scheduler
Este namespace será responsável pelo agendamento e orquestração dos workflows de dados. Para isso, será utilizado o **Apache Airflow**, uma ferramenta amplamente usada no mercado para criação e monitoramento de pipelines de dados (DAGs).

### Viewer
Este namespace será responsável pela visualização dos dados processados pelos pipelines de ETL. Para isso, será utilizado o **Apache Superset**, uma plataforma open source de visualização e exploração de dados.

Com o Superset, será possível criar dashboards, gráficos interativos e realizar consultas diretamente nas fontes de dados conectadas (como bancos relacionais ou data lakes). A implantação será feita no cluster Kubernetes via Helm, garantindo escalabilidade e integração com outras ferramentas do ecossistema.

### Storage
Este namespace será responsável por armazenar arquivos utilizados e gerados pelas aplicações que rodam no cluster. Para isso, será utilizado o **MinIO**, uma solução de armazenamento de objetos compatível com o protocolo S3 da AWS, que pode ser executada localmente de forma leve e eficiente.

Com o MinIO, será possível simular o comportamento de um bucket S3 em ambiente local, o que é extremamente útil para testar integrações com ferramentas como Spark, Airflow e Superset sem depender de serviços externos.

## Criando os Namespaces
Com todos os recursos instalados e o cluster em execução, podemos agora criar os namespaces que serão utilizados para isolar os diferentes componentes da aplicação dentro do cluster Kubernetes.

Execute os comandos abaixo para criar os namespaces:
```bash
kubectl create namespace executor
kubectl create namespace scheduler
kubectl create namespace viewer
kubectl create namespace storage
```

Cada namespace representará uma parte específica da arquitetura (execução, orquestração, visualização e armazenamento), permitindo um gerenciamento mais organizado e seguro dos recursos no cluster.