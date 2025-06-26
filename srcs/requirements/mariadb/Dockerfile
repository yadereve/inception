FROM debian:oldstable

RUN apt update && apt upgrade && apt install -y mariadb-server

# Install dependencies
RUN apt-get clean

COPY ./tools/script.sh /tmp/.

RUN chmod +x /tmp/script.sh

EXPOSE 3306

ENTRYPOINT [ "bash", "/tmp/script.sh" ]
