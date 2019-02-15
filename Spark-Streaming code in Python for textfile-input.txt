# Import spark liabraries

import sys
 
from pyspark import SparkContext

from pyspark.streaming import StreamingContext




# Setup Spark Context and Streaming Context

sc = SparkContext(appName="StreamingErrorFromHDFS")

ssc = StreamingContext(sc,25)



# Input Data Stream from hdfs file - errorlogs file location on hdfs same as defined in flume properties file
ds_lines = ssc.textFileStream("hdfs:///streaming/hdfs/")



# Apply Transformation and Action on DStream


# Break lines into words & Filter words contains "error"

ds_words = dS_lines.flatMap(lambda line: line.split(" ")).filter(lambda word: "error" in word)



# Map the words with number count
ds_pairs = ds_words.map(lambda word:(word,1))

# Return (word,count)

ds_wordCount = ds_pairs.reduceByKey(lambda x, y:x+y)



# Print word count on console once streaming begins
ds_wordCount.pprint()



# Start  data streaming
ssc.start()


# Terminate data streaming at user's choice
ssc.awaitTermination()
