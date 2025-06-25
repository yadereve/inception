FROM debian:oldstable

RUN apt update && apt upgrade && apt install -y mariadb-server

COPY ./tools/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY ./tools/init.sql /etc/mysql/init.sql
COPY ./tools/script.sh /tmp

RUN mkdir /run/mysqld && chmod +x script.sh

ENTRYPOINT [ "bash", "./script.sh" ]
