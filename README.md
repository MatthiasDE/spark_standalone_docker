![Docker Build Status](https://img.shields.io/docker/cloud/build/matthiasde/rbspark.svg)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/matthiasde/rbspark.svg)
![License](https://img.shields.io/github/license/MatthiasDE/spark_standalone_docker.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/matthiasde/rbspark.svg)
![GitHub release](https://img.shields.io/github/release-pre/MatthiasDE/spark_standalone_docker.svg)

Multiple-Node Standalone Spark Container with R and Python 3 support.
SparkR is included. How to use the SparkR integration can be viewed within the SparkExample.R.
The container is based on Alpine Linux.

# Getting Started
This short walkthrough is created for Windows Users with Windows 10 Pro (Windows 10 Home will not work)
* Installed ![Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/)
* Hit [Windows]+[R] and type ```powershell``` or ```cmd.exe``` [Enter] to open command line
* Type ```docker pull matthiasde/rbspark``` [ENTER]
* Wait until download is finished (>1 GB)
* Start container from just downloaded image and enter shell: ```docker run -it --rm matthiasde/rbspark``` [ENTER]
* Start the example R program: ```Rscript --vanilla SparkExample.R```

# Download an Build Process
## Download
You can download the automatically crated Docker Container via Docker Hub ![here](https://hub.docker.com/r/matthiasde/rbspark)

## Container Build Process
* Change to  directory where you cloned with git this repo
* Execute on docker shell or command line  
```docker build -t matthiasde/rbspark .```

# Using the Container Image
## Start the mutliple node cluster
Before starting with commands below it is necessary that you created specific docker network. This is necessary beacuse running containers communicate unlimited from distributed ports within the docker network.

Please create network with: ```docker network create spark_network```


### Master Node
```
docker run -d --net spark_network --name master -p 8080:8080 matthiasde/rbspark /opt/spark/sbin/start-master.sh
```

### Worker Node (Slave)
```
docker run -d --net spark_network matthiasde/rbspark /opt/spark/sbin/start-slave.sh master:7077
```

## Integration Test
* Login to master node  
```docker exec -it master sh```
* Run the unit test with SparkR support on shell ```/opt #```  
```Rscript --vanilla SparkExample.R```

# License
Even when the Github project for creation of this docker image with some example and test programs are licensed under the MIT please be aware - as with all Docker images - that resulting image also contain other software which may be under other licenses. This is explicitely valid for such components as R, Python etc. from the base Alpine distribution & Spark, along with any direct or indirect dependencies of the primary software being contained.

As for any pre-built image usage it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
