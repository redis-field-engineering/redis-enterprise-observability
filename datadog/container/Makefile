#################################################
VERSION ?= latest

default:	docker

docker:
	docker build . -t fieldengineering/redis-cloud-datadog

push-latest:
	docker buildx build \
		--platform linux/amd64 \
		--push \
		-t fieldengineering/redis-cloud-datadog:latest .

push-version:
	docker buildx build \
		--platform linux/amd64 \
		--push \
		-t fieldengineering/redis-cloud-datadog:$(VERSION) .

