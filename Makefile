DOCKER_IMAGE_NAME = opsidian/etcd
DOCKER_IMAGE_TAG ?= latest
SHELL = /bin/bash -e

default:

docker-login:
	@docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} -e ${DOCKER_EMAIL}

build:
	echo -e "repository_url: https://github.com/${TRAVIS_REPO_SLUG}\ncommit_hash: ${TRAVIS_COMMIT}\ntravis_build_url: https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}" > docker/opsidian-release
	docker pull `awk '/^FROM /{print $$2}' docker/Dockerfile`
	docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} docker

upload: docker-login
	docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

run-bash:
	docker run -it --rm -e USER=root ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} bash -l

docker-info:
	@docker run -it --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} docker-info

test:
	@for suite in spec/tests/*_spec.rb; do \
		[ -z "${TEST_SUITE}" ] || [ "spec/tests/${TEST_SUITE}_spec.rb" = "$$suite" ] || continue; \
		echo $$suite; \
		DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME} DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} bundle exec rspec $$suite; \
	done; \

test-deps:
	bundle install --path=vendor/bundle --binstubs=vendor/bin
