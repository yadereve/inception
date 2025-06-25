SRC_DIR=./srcs
DOCKER_COMPOSE=docker compose -f $(SRC_DIR)/docker-compose.yml

all: clean up

up:
	bash $(SRC_DIR)/requirements/nginx/tools/add-host.sh
	# $(DOCKER_COMPOSE) up --build -d
	$(DOCKER_COMPOSE) up --build

build:
	$(DOCKER_COMPOSE) build --no-cache

down:
	$(DOCKER_COMPOSE) down

logs:
	$(DOCKER_COMPOSE) logs -f

clean:
	$(DOCKER_COMPOSE) down -v --rmi all
	$(DOCKER_COMPOSE) rm -f
	sudo rm -rfv $(SRC_DIR)/database

fclean:
	docker system prune -a

re: fclean up

.PHONY: all up down logs clean fclean re
