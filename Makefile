 # Go parameters
    BINARY=date-api
    ORG=sleyva97
    ACTIVE_VERSION=1.4
    ROLLBACK_VERSION=1.3
    DOCKER_IMAGE=$(ORG)/$(BINARY)

    all: docker-push kubernetes-deployment promote-deployment

    docker-build:
	docker build --build-arg VERSION=$(ACTIVE_VERSION) . -t $(DOCKER_IMAGE):$(ACTIVE_VERSION)

    docker-push: docker-build
	docker push $(DOCKER_IMAGE):$(ACTIVE_VERSION)

    kubernetes-deployment:

	# Change pods image and label
	kubectl -n date-api set image \
	deployment/$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	date-api=$(DOCKER_IMAGE):$(ACTIVE_VERSION)
	
	# Re-label oldest deployment and pods
	kubectl -n date-api label deployment \
	$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	"version=${ACTIVE_VERSION}" --overwrite

	kubectl -n date-api label pods \
	$(shell kubectl -n date-api get pods -l "name == $(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})" -o jsonpath={.items[0].metadata.name}) \
	version=${ACTIVE_VERSION}

    promote-deployment:
	kubectl set selector service date-api name=$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) -n date-api