#!/usr/bin/env python
# coding: utf-8

# # IPL_Matches Regression Analysis

# In[1]:

from pyspark.sql import SparkSession

# In[2]:

spark = SparkSession.builder.appName('IPL_Regression_CsvIndexed').getOrCreate()

# In[3]:

df = spark.read.csv('file:///usr/local/Project_IPL/IPLmatches_mod.csv', inferSchema=True, header=True)

# In[4]:

df.printSchema()

# In[5]:

df.count()

# In[6]:

df_analysis = df.select(['season','city','team1','team2','toss_winner','toss_decision',
                         'winner','win_by_runs','win_by_wickets'])

# In[8]:

final_data = df_analysis.na.drop()

# In[9]:

final_data.count()

# In[10]:

final_data.select('team1','team2','toss_winner','winner','win_by_runs','win_by_wickets').show(5)

# In[11]:

final_data.columns

# In[12]:

from pyspark.ml.feature import (VectorAssembler, VectorIndexer,
                                OneHotEncoder, StringIndexer)

# In[13]:

cityIndexer = StringIndexer(inputCol='city', outputCol='cityIndex')
cityEncoder = OneHotEncoder (inputCol='cityIndex', outputCol='cityVec')

# In[14]:

tossDecIndexer = StringIndexer(inputCol='toss_decision', outputCol='tossDecIndex')
tossDecEncoder = OneHotEncoder(inputCol='tossDecIndex', outputCol='tossDecVec')

# In[15]:

assembler = VectorAssembler(inputCols = ['season','cityVec','tossDecVec',
                                         'win_by_runs', 'win_by_wickets'], outputCol = 'features')

# In[16]:

from pyspark.ml.classification import LogisticRegression

# In[17]:

logistic_reg_ipl = LogisticRegression(featuresCol='features', labelCol='winner')

# In[18]:

from pyspark.ml import Pipeline

# In[19]:

pipeline = Pipeline(stages=[cityIndexer,cityEncoder,tossDecIndexer,tossDecEncoder,assembler,logistic_reg_ipl])

# In[20]:

train_data,test_data = final_data.randomSplit([0.7,0.3])

# In[21]:

fit_model = pipeline.fit(train_data)

# In[22]:

results = fit_model.transform(test_data)

# In[23]:

results.select('team1','team2','winner','prediction').show()

# In[24]:

from pyspark.ml.evaluation import MulticlassClassificationEvaluator

# In[25]:

evaluator = MulticlassClassificationEvaluator(predictionCol = 'prediction', labelCol = 'winner')

# In[26]:

predictions = evaluator.evaluate(results)

# In[27]:

predictions

# In[28]:

from pyspark.sql.functions import corr

# In[29]:

df.select(corr('team1','team2')).show()

# In[30]:

df.select(corr('team1','winner')).show()

# In[31]:

df.select(corr('team2','winner')).show()





