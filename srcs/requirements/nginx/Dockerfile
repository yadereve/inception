FROM debian:oldstable

RUN apt update && apt install -y nginx openssl curl

COPY ./conf/default /etc/nginx/sites-available/default
COPY ./tools/script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

EXPOSE 443

ENTRYPOINT [ "bash", "/tmp/script.sh" ]
