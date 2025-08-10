from pyspark.sql import SparkSession
from time import sleep

if __name__ == "__main__":
    spark = SparkSession.builder.appName("WordCountExample").getOrCreate()

    # Texto de exemplo
    data = [
        "Apache Spark é um mecanismo de análise de dados",
        "Spark é rápido e fácil de usar",
        "Executando Spark no Kubernetes com Spark Operator"
    ]

    # Cria um RDD com o texto
    rdd = spark.sparkContext.parallelize(data)

    # Processa o texto: separa palavras e faz contagem
    word_counts = (
        rdd.flatMap(lambda line: line.split(" "))
           .map(lambda word: (word.lower(), 1))
           .reduceByKey(lambda a, b: a + b)
    )

    # Converte para DataFrame e mostra o resultado
    df = word_counts.toDF(["word", "count"])
    df.show()

    spark.stop()
