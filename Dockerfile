# syntax = docker/dockerfile:1.0-experimental

FROM mcr.microsoft.com/mssql/server

ENV ACCEPT_EULA=yes

USER root

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

COPY icmdb.sql startup.sh /

RUN --mount=type=secret,id=sa_pw export MSSQL_SA_PASSWORD=$(cat /run/secrets/sa_pw ) && \
    ( /opt/mssql/bin/sqlservr --reset-sa-password & ) && \
    sleep 20 && \
    echo "start complete" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ${MSSQL_SA_PASSWORD} -q quit && \
    /opt/mssql-tools/bin/sqlcmd -b -S localhost -U sa -P ${MSSQL_SA_PASSWORD} -i /icmdb.sql && \
    sleep 10 && \
    ps -j -C sqlservr --no-headers | awk "{print \$1}" | xargs kill && \
    sleep 10 && \
    chown mssql:root /opt/mssql /var/opt/mssql -R

EXPOSE 1433

USER mssql

CMD [ "bash", "/startup.sh" ]

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=8 CMD [ "/opt/mssql-tools/bin/sqlcmd", "-b", "-S", "localhost", "-U", "intershop", "-P", "intershop", "-q", "quit" ]
