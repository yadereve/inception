SRC_DIR=./srcs
DOCKER_COMPOSE=docker compose -f $(SRC_DIR)/docker-compose.yml

# detect 42 login dynamically if possible
LOGIN=$(USER)

all: up

up:
	bash $(SRC_DIR)/requirements/nginx/tools/add-host.sh
	mkdir -p /home/$(LOGIN)/data/wp-data /home/$(LOGIN)/data/mariadb-data
	$(DOCKER_COMPOSE) up --build -d

down:
	$(DOCKER_COMPOSE) down -v

build:
	$(DOCKER_COMPOSE) build

clean: down
	sudo rm -rfv /home/$(LOGIN)/data

# Safer eval: only cleans project resources, not global Docker system
eval:
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	docker volume prune -f
	docker network prune -f

logs:
	$(DOCKER_COMPOSE) logs -f

re: clean all

.PHONY: all up down clean eval logs re build
