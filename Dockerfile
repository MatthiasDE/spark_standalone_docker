# "Dockerfile" with cap D without extension is standard name

#--- FROM is first command that give base image; here Alpine Linux
FROM alpine

LABEL version="0.8"
LABEL maintainer="matthiaslink<AT>gmx.de"
LABEL description="Standalone Multi-Node-Spark with R & Python3"

#--- Variables
ENV SPARK_VERSION=2.4.0
ENV HADOOP_VERSION=2.7
ENV SPARK_NO_DAEMONIZE=true

#--- RUN is any command that can be run in linux terminal
#Update Alpine Linux
RUN apk update && apk upgrade

# Install necessary dependencies
#   for Spark: bash coreutils openjdk-jre procps
#   for RB Pipeline: python3 R
#   for Docker Build Process: tar
RUN apk add bash \
    coreutils \
    openjdk8-jre \
    procps \
    python3 \
    R \
    tar

# Install Spark
WORKDIR /opt
#following is resulting in something as "http://apache.mirror.digionline.de/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz" with vars
RUN wget http://apache.mirror.digionline.de/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    tar -xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION spark
ENV SPARK_HOME="/opt/spark"

#--- Prerequisits for Python Module and R Package Installs
#for R devtools; Python pyodbc: alpine-sdc (e.g. gcc g++)
#for R devtools: R-dev
#for Python pyodbc: python3-dev unixodbc unixodbc-dev
RUN apk add alpine-sdk \
    python3-dev \
    R-dev \
    unixodbc \
    unixodbc-dev

#--- Install Python Modules
# Insert your modules that has to be installed here and uncomment and add additional lines as needed, e.g.
#RUN pip3 install sqlalchemy \
#    pyodbc
#RUN pip3 install <yourmodule>

#--- Install R Packages
COPY setup.R .
RUN Rscript --vanilla ./setup.R

#port 8080 to be exposed that the Spark master UI can be runned (e.g. for verify spark is running etc.), 8081 is used for statistics for workers
#port 7077 don't has to be exposed when docker network and docker --net is used (containers can communicate unlimited within one defined network)
EXPOSE 8080 8081

#Install application specific test script & SparkR unit test
COPY SparkExample.R .
