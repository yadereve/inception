FROM debian:oldstable

RUN apt update && apt upgrade && apt install -y nginx openssl

COPY default /etc/nginx/sites-available/default
COPY script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT [ "./script.sh" ]
