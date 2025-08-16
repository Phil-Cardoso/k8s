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
