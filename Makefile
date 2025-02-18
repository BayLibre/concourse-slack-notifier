DOCKER_PREFIX=baylibre
DOCKER_NAME=concourse-slack-notifier

all: docker

docker:
	docker build . \
		--tag "$(DOCKER_NAME):latest"

push: docker
		docker image tag ${DOCKER_NAME} ${DOCKER_PREFIX}/${DOCKER_NAME}
		docker push ${DOCKER_PREFIX}/${DOCKER_NAME}
