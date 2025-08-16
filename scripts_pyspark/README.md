# Executar Script no Kubernetes

## Dependencias
Para executar um script dentro de um cluster Kubernetes (K8s), são necessários os seguintes arquivos:
* **Script principal** (por exemplo: `main.py`)
* **Arquivos auxiliares** utilizados pelo script (módulos, dados, configs, etc.)
* **Arquivo** `requirements.txt` com as bibliotecas e versões necessárias
* **Dockerfile** para construir a imagem do container com o ambiente apropriado
* **GitHub Container Registry (GHCR)** para registrar as imagens construidas a partir do `dockerfile`
* **Manifesto YAML** com as instruções para criação da aplicação (Pod, Job, Deployment, etc.)

## Script principal
O script principal é o arquivo que contém o código a ser executado com um objetivo específico.
Neste exemplo, dentro da pasta `scripts_pyspark\exemplo`, foi criado um arquivo chamado `pi.py`.

Esse script realiza uma estimativa do valor de π utilizando PySpark, após aguardar 30 segundos.

```python
from pyspark.sql import SparkSession
import random
from time import sleep

print('esperando 30 segundos')
sleep(30)
print('iniciando spark')

spark = SparkSession.builder.appName("PiEstimation").getOrCreate()
sc = spark.sparkContext

def inside(p):
    x, y = random.random(), random.random()
    return x*x + y*y < 1

count = sc.parallelize(range(0, 100000)).filter(inside).count()
print("Pi is roughly %f" % (4.0 * count / 100000))

spark.stop()
```

## Arquivos auxiliares
No exemplo apresentado, o script não utiliza nenhum arquivo auxiliar.

No entanto, em projetos mais complexos, é comum incluir arquivos auxiliares que contêm **funções** (`def`), **classes** (`class`), **configurações**, **variáveis de ambiente** ou **dados** que podem ser reutilizados em diferentes partes da aplicação.

> <span style="color:red"><strong>Importante:</strong></span> As *variáveis de ambiente* mencionadas aqui não incluem informações sensíveis como senhas, tokens ou chaves de acesso. Esses dados confidenciais devem ser armazenados de forma segura, utilizando os **Secrets** do Kubernetes.

Esses arquivos ajudam a organizar melhor o código, promover reutilização e facilitar a manutenção.

## Arquivo `requirements.txt`
O arquivo `requirements.txt` lista as bibliotecas externas utilizadas no desenvolvimento do script, garantindo que o ambiente de execução tenha todas as dependências necessárias.

No exemplo apresentado, foram importadas as seguintes bibliotecas:

* `from pyspark.sql import SparkSession`
* `import random`
* `from time import sleep`

No entanto:
* A biblioteca `pyspark` já está incluída na imagem base do `spark-operator`, assim como diversas outras funcionalidades do Spark — por isso, **não é necessário adicioná-la manualmente** ao `requirements.txt`.

* As bibliotecas `random` e `time` fazem parte da biblioteca padrão do Python, e **também não precisam ser listadas**.

### Exemplo de bibliotecas que precisariam ser declaradas
Caso seu script utilizasse outras bibliotecas externas (não inclusas por padrão no ambiente base), elas deveriam ser declaradas no `requirements.txt`, como por exemplo:

```txt
pandas==2.2.2
numpy==1.26.4
requests==2.31.0
```

### Dica
Caso não tenha certeza de quais bibliotecas serão utilizadas em um script, você pode:

1. Criar um ambiente virtual local com virtualenv:
```bash
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate
```

2. Realizar o desenvolvimento e testar seu código dentro desse ambiente.

3. Ao final, gerar automaticamente o arquivo `requirements.txt` com o seguinte comando:
```bash
pip freeze > requirements.txt
```

Isso garantirá que todas as bibliotecas (e suas versões) utilizadas no desenvolvimento estejam corretamente listadas para replicação do ambiente em produção, visto que o `virtualenv` cria um ambiente isolado para o seu script.

## Dockerfile
O `Dockerfile` é o arquivo responsável por construir a imagem Docker que será utilizada dentro do Kubernetes (K8s), incluindo o script principal e todas as suas dependências.

Abaixo está um exemplo de `Dockerfile` criado para o script `pi.py`, localizado na pasta `scripts/`:

```dockerfile
FROM bitnami/spark:3.5

WORKDIR /opt/spark-apps

# Copia o script para dentro da imagem
COPY pi.py .

# Copia e instala as dependências, se houver
COPY requirements.txt .
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi
```

### Explicação

```dockerfile
FROM bitnami/spark:3.5
```
* Define a imagem base que será usada para construir a nova imagem.
* A imagem `bitnami/spark:3.5` já vem com o Apache Spark pré-instalado e configurado para rodar em ambientes Kubernetes. Isso evita a necessidade de configurar o Spark manualmente.

```dockerfile
WORKDIR /opt/spark-apps
```
* Define o diretório de trabalho dentro da imagem.
* Todos os comandos posteriores serão executados a partir de `/opt/spark-apps`.

```dockerfile
COPY pi.py .
```
* Copia o arquivo `pi.py` (script principal) do seu diretório local para dentro da imagem, dentro da pasta `/opt/spark-apps`.
* O ponto final (`.`) indica que o destino é o diretório de trabalho atual (definido anteriormente com `WORKDIR`).

```dockerfile
COPY requirements.txt .
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi
```
* Copia o arquivo `requirements.txt` para dentro da imagem.
* Em seguida, executa um comando `RUN` que:
    * Verifica se o arquivo `requirements.txt` existe
    * Se existir, instala todas as bibliotecas listadas usando `pip install`
    * A opção `--no-cache-dir` evita armazenar arquivos temporários.

Esse passo garante que todas as bibliotecas necessárias para o script sejam instaladas no ambiente da imagem.

## GitHub Container Registry (GHCR)

Para realizar um processo mais próximo de um ambiente real de produção, este exemplo mostra como publicar uma imagem no **GitHub Container Registry (GHCR)**.

O GHCR é gratuito, permite criar repositórios **privados** de imagens e, caso necessário, pode ser integrado facilmente com **GitHub Actions** para automatizar pipelines de CI/CD.

A seguir, estão descritas as etapas de configuração. Vale lembrar que é necessário ter uma conta no [GitHub](https://github.com).

---

### 1. Build da imagem localmente

Antes de começar, certifique-se de que você:

* Possui uma conta no [GitHub](https://github.com)
* Tem o Git configurado corretamente em sua máquina

Agora, acesse a pasta onde está localizado o `Dockerfile` desejado e execute o comando abaixo para construir a imagem:

```bash
docker build -t ghcr.io/SEU_USUARIO/NOME_DA_IMAGEM:latest .
```

* `docker build`: comando responsável por construir a imagem
* `-t`: define a tag (nome + versão) da imagem
* `ghcr.io`: especifica que a imagem será usada com o **GitHub Container Registry**
* `SEU_USUARIO`: seu nome de usuário no GitHub
* `NOME_DA_IMAGEM`: nome que você deseja dar à imagem
* `latest`: tag da imagem (versão). Neste caso, usamos `latest` como padrão
* `.`: indica que o Dockerfile está no diretório atual

Exemplo:
```bash
docker build -t ghcr.io/phil-cardoso/spark-pi:latest .
```

### 2. Autenticar-se no GHCR

#### Gere um token no GitHub:
1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token" (classic ou fine-grained)
3. Dê as permissões:
    * `read:packages`
    * `write:packages`
    * `delete:packages` (*opcional, mas recomendado*)
4. Copie o token e **guarde com segurança**

#### Faça login no terminal:
```bash
echo <SEU_TOKEN> | docker login ghcr.io -u SEU_USUARIO --password-stdin
```
* `<SEU_TOKEN>`: o token que você acabou de gerar
* `SEU_USUARIO` seu nome de usuário no GitHub

### 3. Push da imagem para o GHCR
Depois de realizar o build e o login com sucesso, execute:
```bash
docker push ghcr.io/SEU_USUARIO/NOME_DA_IMAGEM:latest
```

Exemplo:
```bash
docker push ghcr.io/phil-cardoso/spark-pi:latest
```

### 4. Visualizar imagem no github
Para verificar se o processo foi bem-sucedido, acesse:

`https://github.com/users/SEU_USUARIO/packages`

Lá você poderá visualizar a imagem publicada, junto com a tag informada (por exemplo: `latest`).

### Observasões
* Após a primeira configuração, **não é necessário repetir os passos de login**, apenas o build e push das novas versões das imagens.
* Fique atento à **expiração do token**. É uma boa prática usar tokens com validade limitada e renová-los periodicamente para garantir segurança.

## Manifesto YAML
