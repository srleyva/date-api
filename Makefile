 # Go parameters
    BINARY=date-api
    ORG=sleyva97
    ACTIVE_VERSION=1.2
    ROLLBACK_VERSION=1.1
    DOCKER_IMAGE=$(ORG)/$(BINARY)

    all: docker-push kubernetes-deploy

    docker-build:
	docker build --build-arg VERSION=$(ACTIVE_VERSION) . -t $(DOCKER_IMAGE):$(ACTIVE_VERSION)

    docker-push: docker-build
	docker push $(DOCKER_IMAGE):$(ACTIVE_VERSION)

    kubernetes-deploy:
    # $(eval new_deployment=shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})
	
	# Re-label oldest deployment and pods
	kubectl -n date-api label deployment \
	$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	"version=${ACTIVE_VERSION}" --overwrite

	# Change pods image and label
	kubectl -n date-api set image \
	deployment/$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	date-api=$(DOCKER_IMAGE):$(ACTIVE_VERSION)

	kubectl -n date-api label pods \
	$(shell kubectl -n date-api get pods -l "name == $(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})" -o jsonpath={.items[0].metadata.name}) \
	version=${ACTIVE_VERSION}

    promote-deploy:
	kubectl set selector service date-api name=$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) -n date-api