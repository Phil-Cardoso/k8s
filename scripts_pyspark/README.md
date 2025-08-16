# Executar Script no Kubernetes

## Dependencias
Para executar um script dentro de um cluster Kubernetes (K8s), são necessários os seguintes arquivos:
* **Script principal** (por exemplo: `main.py`)
* **Arquivos auxiliares** utilizados pelo script (módulos, dados, configs, etc.)
* **Arquivo** `requirements.txt` com as bibliotecas e versões necessárias
* **Dockerfile** para construir a imagem do container com o ambiente apropriado
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

## Manifesto YAML
