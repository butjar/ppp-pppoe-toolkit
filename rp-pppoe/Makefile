IMAGE ?= rp-pppoe
TAG ?= latest

.PHONY: all build
all: build

.PHONY: build
build: Dockerfile
	docker build -t $(IMAGE):$(TAG) .

.PHONY: clean
clean:
	docker rmi $(IMAGE):$(TAG)
