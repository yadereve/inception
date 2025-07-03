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
	docker rmi -f $(docker images -qa)
	docker volume rm $(docker volume ls -q)
	docker network rm $(docker network ls -q) 2>/dev/null

eval:
	docker stop $(docker ps -qa);
	docker rm $(docker ps -qa);
	docker rmi -f $(docker images -qa);
	docker volume rm $(docker volume ls -q);
	docker network rm $(docker network ls -q) 2>/dev/null;

logs:
	$(DOCKER_COMPOSE) logs -f

re: clean all

.PHONY: all up down clean eval logs re
