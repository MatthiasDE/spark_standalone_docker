# "Dockerfile" with cap D without extension is standard name
# Building with > docker build -t matthiasde/rbspark .

#--- FROM is first command that give base image ---
FROM alpine

LABEL version="0.8"
LABEL maintainer="matthiaslink<AT>gmx.de"
LABEL description="Standalone Multi-Node-Spark with R & Python3"

#--- Variables
ENV SPARK_VERSION=2.4.0
ENV HADOOP_VERSION=2.7
ENV SPARK_NO_DAEMONIZE=true

#--- RUN is any command that can be run in linux terminal ---
#Update Alpine Linux
RUN apk update && apk upgrade
#Install necessary dependencies
#RUN apk add curl ca-certificates tar supervisor bash procps coreutils
#for Spark: bash coreutils openjdk-jre procps
#for RB Pipeline: python3 R
#for Docker Build Process: tar
RUN apk add bash \
    coreutils \
    openjdk8-jre \
    procps \
    python3 \
    R \
    tar

#--- Java install as per manual in https://wiki.alpinelinux.org/wiki/Installing_Oracle_Java
#RUN ["mkdir", "java"]
#RUN ["wget", "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jre-8u201-linux-x64.tar.gz"
#run ["tar", "-xzf", "jre-8u201-linux-x64.tar.gz"]
#### done above: RUN apk add openjdk8-jre

#--- Spark install as per manual in https://anchormen.nl/blog/big-data-services/spark-docker/ & https://github.com/vinicius85/docker/blob/master/sparkr-rstudio/Dockerfile
WORKDIR /opt
#RUN ["wget", "http://apache.mirror.digionline.de/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz"]
RUN wget http://apache.mirror.digionline.de/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    tar -xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION spark
ENV SPARK_HOME="/opt/spark"

#--- Install Python Modules
RUN pip3 install sqlalchemy		#for RB Pipeline
#for pyodbc (not tested!)
RUN apk add R-dev alpine-sdk
#RUN apk add g++
#RUN pip install pyodbc


#--- Install R Packages
#ADD resources/setup.R /tmp/setup.R
#RUN Rscript --vanilla /tmp/setup.R
#see https://stackoverflow.com/questions/31184918/installing-of-sparkr
#install.packages("https://cran.r-project.org/src/contrib/Archive/SparkR/SparkR_2.3.0.tar.gz", repos = NULL, type="source")
#some hints also on following page: https://gist.github.com/adgaudio/11312117
# configure R with default mirror for package installs
#RUN echo 'options(repos=structure(c(CRAN="http://lib.stat.cmu.edu/R/CRAN/")))' >> ~/.Rprofile

#RUN fp="/tmp/sparkR.$$"

#benötigt ??     install.packages("rJava") \
#RUN cat > $fp <<EOF \
#    install.packages("devtools") \
#    library(devtools) \
# install_github("amplab-extras/SparkR-pkg", subdir="pkg")  # done in prior step
#EOF
#RUN Rscript $fp
#RUN rm $fp

# install sparkr
#RUN git clone https://github.com/amplab-extras/SparkR-pkg
#RUN (cd SparkR-pkg ; \
# SPARK_HADOOP_VERSION="2.0.0-mr1-cdh4.4.0" ./install-dev.sh ; \
# # inject sparkr library into R libPath 
# echo ".libPaths(c(\"`pwd`/lib\", .libPaths()))" >> ~/.Rprofile \
#)

#port 8080 to be exposed that the Spark master UI can be runned (e.g. for verify spark is running etc.), 8081 is used for statistics for workers
#port 7077 don't has to be exposed when docker network and docker --net is used (containers can communicate unlimited within one defined network)
EXPOSE 8080 8081

COPY setup.R .
RUN Rscript --vanilla ./setup.R

#Install application specific scripts
COPY SparkExample.R .

#Run it in the cluster is documented in the spark docker manual above
#docker run -d --net spark_network --name master -p 8080:8080 matthiasde/rbspark /opt/spark/sbin/start-master.sh
#docker run -d --net spark_network matthiasde/rbspark /opt/spark/sbin/start-slave.sh master:7077
