# MSSQL Intershop Database Preparation

Using this project you can create your own Microsoft SQL database docker container prepared to be used as database for Intershop Commerce Management for development purposes.

## Preliminaries

- This image uses the latest mssql server as it is provided in mcr.microsoft.com/mssql/server. 
- For demonstration purposes, it uses the --secret mechanism from docker buildkit to pass passwords to the image build process.

## Usage

- Create a strong password and put it into the file `sa_pw.txt` which is under gitignore control:

```bash
$ pwgen -1 23 -y > sa_pw.txt
```

- The password file is used by the sophisticated docker builkit image build process.
- Switch buildkit mode on and build the image:

```bash
$ export DOCKER_BUILDKIT="1"
$ docker build --no-cache --progress=plain --secret id=sa_pw,src=sa_pw.txt -t mssql-ish .
```

- Note, how the Dockerfile uses the preamble to load dockerfile buildkit extensions:

```bash
± cat Dockerfile | head -1
# syntax = docker/dockerfile:1.0-experimental
```

## Startup the server

```bash
$ docker run -it -p 1433 mssql-ish
```

- Note, you can run the container in daemon mode. If so, use -d instead of -it.


## Configuring your environment

To connect your local ICM development environment with the local docker mssql database your configuration in the `environment.properties` of your development machine should look like this.
```
# Database configuration
databaseType = mssql
jdbcUrl = jdbc:sqlserver://localhost:1433;database=DB;
databaseUser = intershop
databasePassword = intershop

# these partly Oracle specific settings are still needed for the deployment script
databaseHost = DB
databasePort = 1433
databaseTnsAlias = ISSERVER.world
databaseServiceName = XE
oracleClientDir = C:/Oracle/client12cR1
```
