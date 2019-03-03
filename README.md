# spark_standalone_docker
Multiple-Node Standalone Spark with R and Python

## Presumption
* Installed Docker e.g. (Docker for Windows)
* Created specific docker network (beacuse machines communicate unlimited from distributed ports within the docker network)
```docker network create spark_network```

## Start the mutliple node cluster
Run it in the cluster is documented in the spark docker manual above

### Master Node
```
docker run -d --net spark_network --name master -p 8080:8080 matthiasde/rbspark /opt/spark/sbin/start-master.sh
```

### Slave Node
```
docker run -d --net spark_network matthiasde/rbspark /opt/spark/sbin/start-slave.sh master:7077
```
