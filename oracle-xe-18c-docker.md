# Installing Oracle XE 18c using Docker

Clone de oracle docker-images repository:
```
cd ~
git clone https://github.com/oracle/docker-images.git
```

Build docker image:
```
cd ~/docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildDockerImage.sh -v 18.4.0 -x
```

List the docker images to verify it got created:
```
docker images
```

The data volume /opt/oracle/oradata lets you preserve the database’s data and configuration files on the host file system in case the container is deleted. 

The directory must be writable by a user with UID 54321, which is the oracle user within the container.
```
mkdir -p /opt/oraclexe/oradata
mkdir -p /opt/oraclexe/scripts/setup
mkdir -p /opt/oraclexe/scripts/startup
chown 54321:54321 /opt/oraclexe  
```

Start the docker container binding on localhost
```
docker run --name oraclexe \
    -d \
    --rm \
    -p 51521:1521 \
    -p 55500:5500 \
    -e ORACLE_PWD=OracleXe \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v /opt/oraclexe/oradata:/opt/oracle/oradata \
    -v /opt/oraclexe/scripts/setup:/opt/oracle/scripts/setup \
    -v /opt/oraclexe/scripts/startup:/opt/oracle/scripts/startup \
    oracle/database:18.4.0-xe
```

Start the docker container binding on external IP address
```
docker run --name oraclexe \
    -d \
    --rm \
    -p 192.168.0.80:1521:1521 \
    -p 192.168.0.80:5500:5500 \
    -e ORACLE_PWD=OracleXE \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v /opt/oraclexe/oradata:/opt/oracle/oradata \
    -v /opt/oraclexe/scripts/setup:/opt/oracle/scripts/setup \
    -v /opt/oraclexe/scripts/startup:/opt/oracle/scripts/startup \
    oracle/database:18.4.0-xe
```

Stopping the oraclexe container
```
docker container stop oraclexe
```

Connecting to the database using SQL Plus
```
# main database
sqlplus sys/OracleXE@//192.168.0.80:1521/XE as sysdba

# sample PDB
sqlplus sys/OracleXE@//192.168.0.80:1521/XEPDB1 as sysdba
```

Based on
https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers


