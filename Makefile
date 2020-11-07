#!/usr/bin/make -f
DOCKER_COMPOSE=docker-compose
DOCKER_COMPOSE_FILE=docker-compose.yml
WORKDIR=/home/docker/sites

.DEFAULT_GOAL := list
list:
	@$(MAKE) -qprR -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F':' '/^[a-zA-Z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort |  egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: list up stop start status restart install

# Docker commands.
up: # Start containers for this project
	${DOCKER_COMPOSE} up -d
	${DOCKER_COMPOSE} ps
stop: # Stop containers for this project
	${DOCKER_COMPOSE} down
status: # Display status of containers related to this project
	${DOCKER_COMPOSE} ps
restart: docker-stop docker-start # Restart containers for this project

#cache verify
verify:
	${DOCKER_COMPOSE} exec -u docker web npm cache verify
#Clear old content
clean:
	${DOCKER_COMPOSE} exec -u docker web rm -rf ./node_modules
	${DOCKER_COMPOSE} exec -u docker web rm package-lock.json
# Install node packages.
install: verify
	${DOCKER_COMPOSE} exec -u docker web npm install

# Start grunt serve
start: # cache rebuild
	${DOCKER_COMPOSE} exec -u docker web /home/docker/sites/node_modules/grunt-cli/bin/grunt serve

# build grunt serve
build: # cache rebuild
	${DOCKER_COMPOSE} exec -u docker web /home/docker/sites/node_modules/grunt-cli/bin/grunt build

