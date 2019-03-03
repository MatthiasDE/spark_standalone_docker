if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  sprintf("ERROR: SPARK_HOME environment variable not set. Set to spark installation directory (e.g. /opt/spark)!")
}
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "2g"))
df <- as.DataFrame(faithful)
head(df)
# Convert waiting time from hours to seconds.
# Note that we can apply UDF to DataFrame.
schema <- structType(structField("eruptions", "double"), structField("waiting", "double"),
                     structField("waiting_secs", "double"))
df1 <- dapply(df, function(x) { x <- cbind(x, x$waiting * 60) }, schema)
head(collect(df1))
# Convert waiting time from hours to seconds.
# Note that we can apply UDF to DataFrame and return a R's data.frame
ldf <- dapplyCollect(
         df,
         function(x) {
           x <- cbind(x, "waiting_secs" = x$waiting * 60)
         })
head(ldf, 3)
# Perform distributed training of multiple models with spark.lapply. Here, we pass
# a read-only list of arguments which specifies family the generalized linear model should be.
families <- c("gaussian", "poisson")
train <- function(family) {
  model <- glm(Sepal.Length ~ Sepal.Width + Species, iris, family = family)
  summary(model)
}
# Return a list of model's summaries
model.summaries <- spark.lapply(families, train)

# Print the summary of each model
print(model.summaries)

