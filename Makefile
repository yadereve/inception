SRC_DIR=./srcs
DOCKER_COMPOSE=docker compose -f $(SRC_DIR)/docker-compose.yml

all: up

up:
	bash $(SRC_DIR)/requirements/nginx/tools/add-host.sh
	mkdir -p /home/yadereve/data/wp-data/ /home/yadereve/data/mariadb-data/
	$(DOCKER_COMPOSE) up --build -d

down:
	$(DOCKER_COMPOSE) down -v

clean: down
	sudo rm -rfv /home/yadereve/data

logs:
	$(DOCKER_COMPOSE) logs -f

re: clean all

.PHONY: all up down clean logs re
