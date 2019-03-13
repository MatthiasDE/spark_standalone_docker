if (nchar(Sys.getenv("SPARK_HOME")) < 1) {^M
  sprintf("ERROR: SPARK_HOME environment variable not set. Set to spark installation directory
}
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))^M
sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "2g"))
a <- list()
for (i in 1:10) {
a <- c(a, i)
}
b <- spark.lapply(a,function(x) { return(Sys.getenv("HOSTNAME"))})
print(b)
sparkR.stop()