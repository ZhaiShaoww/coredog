.PHONY: genpb
genpb:
	protoc -I pb pb/*.proto --go_out=plugins=grpc:pb

IMAGE_NAME=coredog
DOCKER_REPO=coderflyfyf
VERSION=$(shell git describe --tags --abbrev=0 2>/dev/null || echo 'latest')

.PHONY: build
build:
	docker build -t $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION) .

.PHONY: push
push: build
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

.PHONY: update-chart
update-chart:
	sed -i 's/image.tag: .*/image.tag: $(VERSION)/' charts/values.yaml
	yq e -i '.version = "$(VERSION)"' charts/Chart.yaml
	yq e -i '.appVersion = "$(VERSION)"' charts/Chart.yaml

.PHONY: push-chart
push-chart: update-chart
	helm package chart
	helm push charts/ $(DOCKER_REPO)
