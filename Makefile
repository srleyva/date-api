 # Go parameters
    BINARY=date-api
    ORG=020853624727.dkr.ecr.us-east-2.amazonaws.com
    ACTIVE_VERSION=1.8
    ROLLBACK_VERSION=1.7
    DOCKER_IMAGE=$(ORG)/$(BINARY)

    all: docker-push kubernetes-deployment promote-deployment

    unit-test:
	go test ./...

    docker-integration:
	docker-compose build --build-arg VERSION=$(ACTIVE_VERSION)
	docker-compose up --exit-code-from test | grep test_1
	docker-compose push

    docker-push:
	docker pull $(DOCKER_IMAGE):$(shell git rev-parse HEAD)
	docker tag $(DOCKER_IMAGE):$(shell git rev-parse HEAD) $(DOCKER_IMAGE):$(ACTIVE_VERSION)
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
	version=${ACTIVE_VERSION} --overwrite

    rollout-wait:
	deployment_wait.sh $(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})

    promote-deployment:
	kubectl set selector service date-api name=$(shell kubectl -n date-api get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) -n date-api

    rollback:
	@read -p "Are you sure you want to rollback deployment $(ACTIVE_VERSION) to $(ROLLBACK_VERSION)? [y/n]:" input; \
	if [ $$input != "y" ]; then printf "%s\n" "Rollback aborted"; exit 0; fi
	@echo "Rolling back $(ACTIVE_VERSION) to $(ROLLBACK_VERSION)"
	kubectl set selector service date-api name=$(shell kubectl -n date-api get deployments -l "version == $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) -n date-api

