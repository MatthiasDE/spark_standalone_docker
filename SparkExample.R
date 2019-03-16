# Some parts of this program are taken out of the Spark documentation (see reference for the distinct code snippets).
# The respective snippets are copied and joint together for this example/test program.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  sprintf("ERROR: SPARK_HOME environment variable not set. Set to spark installation directory (e.g. /opt/spark)!")
}

#Load SparkR package and connect R progrem to the Spark cluster
#Reference and credit: https://spark.apache.org/docs/latest/sparkr.html#starting-up-from-rstudio
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "2g"))

#Example 1
#Create SparkDataFrame out of R faithful example dataset and print first lines
#Reference and credit: https://spark.apache.org/docs/latest/sparkr.html#from-local-data-frames
df <- as.DataFrame(faithful)
head(df)

#Example 2
#Apply user defined function to the SparkDataFrame with converting waiting time from hours to seconds and print first lines
#Reference and credit: https://spark.apache.org/docs/latest/sparkr.html#dapply
schema <- structType(structField("eruptions", "double"), structField("waiting", "double"),
                     structField("waiting_secs", "double"))
df1 <- dapply(df, function(x) { x <- cbind(x, x$waiting * 60) }, schema)
head(collect(df1))

#Example 3
#Apply user defined funtion to the SparkDataFrame with convert waiting time from hours to seconds and pull results
#back into an R data.frame. Furthermore print first lines.
#Reference and credit: https://spark.apache.org/docs/latest/sparkr.html#dapplycollect
ldf <- dapplyCollect(
         df,
         function(x) {
           x <- cbind(x, "waiting_secs" = x$waiting * 60)
         })
head(ldf, 3)

#Example 4 - TEST THE DISTRIBUTION
#Apply a function to a list and distribute computation within the Spark Cluster.
#Reference and credit: https://spark.apache.org/docs/latest/sparkr.html#run-local-r-functions-distributed-using-sparklapply
families <- c("gaussian", "poisson")
train <- function(family) {
  model <- glm(Sepal.Length ~ Sepal.Width + Species, iris, family = family)
  summary(model)
}
# Return a list of model's summaries
model.summaries <- spark.lapply(families, train)

# Print the summary of each model
print(model.summaries)

