# Installing Oracle XE 18c using Docker

Clone de oracle docker-images repository:
```
cd ~
git clone https://github.com/oracle/docker-images.git
```

Build docker image:
```
cd ~/docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 18.4.0 -x
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
    -p 192.168.0.50:1521:1521 \
    -p 192.168.0.50:5500:5500 \
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
sqlplus sys/OracleXE@//192.168.0.50:1521/XE as sysdba
```

Creating a PDB with an ADMIN user
```
create pluggable database "PDBNAME"
    admin user "PDBNAMEADM" identified by PDBNAMEPWD
        ROLES=(DBA)
    STORAGE (MAXSIZE 2G)
    DEFAULT TABLESPACE PDBNAME
    file_name_convert = ('/opt/oracle/oradata/XE/pdbseed/', '/opt/oracle/dbs/pdbname/');

alter pluggable database "PDBNAME" open read write;
```

Creating creating a user with user for the application
```
ALTER SESSION SET CONTAINER = PDBNAME;
CREATE USER PDBNAME_APP IDENTIFIED BY PDBNAME_APP_PWD CONTAINER=CURRENT;
GRANT CREATE SESSION TO PDBNAME_APP CONTAINER=CURRENT;
```

Dropping the application user
```
ALTER SESSION SET CONTAINER = PDBNAME;

REVOKE CREATE SESSION FROM PDBNAME_APP;

DROP USER PDBNAME_APP;
```

Dropping the PDB
```
alter pluggable database "PDBNAME" close;

ALTER SESSION SET CONTAINER = CDB$ROOT;
drop pluggable database PDBNAME including datafiles;
```

Connecting to the PDB using SQL Plus
```
sqlplus PDBNAMEADM/PDBNAMEPWD@//192.168.0.80:1521/PDBNAME
```

Based on
https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers


