FROM debian:oldstable

RUN apt update && apt install -y mariadb-server

# Install dependencies
RUN apt clean

COPY ./tools/script.sh /tmp/script.sh

RUN chmod +x /tmp/script.sh

EXPOSE 3306

ENTRYPOINT [ "bash", "/tmp/script.sh" ]
