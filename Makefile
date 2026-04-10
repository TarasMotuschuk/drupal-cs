IMAGE ?= drupal-cs:latest
PUBLISH_IMAGE ?= timtom6891/drupal-cs:latest
PLATFORMS ?= linux/amd64,linux/arm64
COMPOSE := docker compose
SERVICE := drupal-cs

.PHONY: build build-amd64 build-multiarch-push version init-configs phpcs phpcbf drupal-check phpstan rector twigcs twigcbf composer-normalize shell

build:
	docker build -t $(IMAGE) .

build-amd64:
	docker buildx build --platform linux/amd64 -t $(IMAGE) --load .

build-multiarch-push:
	docker buildx build --platform $(PLATFORMS) -t $(PUBLISH_IMAGE) --push .

version:
	$(COMPOSE) run --rm $(SERVICE)

init-configs:
	$(COMPOSE) run --rm $(SERVICE) drupal-cs-init

phpcs:
	$(COMPOSE) run --rm $(SERVICE) phpcs --standard=Drupal,DrupalPractice web/modules/custom

phpcbf:
	$(COMPOSE) run --rm $(SERVICE) phpcbf --standard=Drupal web/modules/custom

drupal-check:
	$(COMPOSE) run --rm $(SERVICE) drupal-check web/modules/custom

phpstan:
	$(COMPOSE) run --rm $(SERVICE) phpstan analyse web/modules/custom

rector:
	$(COMPOSE) run --rm $(SERVICE) rector process web/modules/custom

twigcs:
	$(COMPOSE) run --rm $(SERVICE) twigcs

twigcbf:
	$(COMPOSE) run --rm $(SERVICE) twigcbf

composer-normalize:
	$(COMPOSE) run --rm $(SERVICE) composer-normalize

shell:
	$(COMPOSE) run --rm $(SERVICE) sh
