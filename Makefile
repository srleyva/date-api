 # Go parameters
    BINARY=date-api
    ACTIVE_VERSION=1.12
    ROLLBACK_VERSION=1.11
    DOCKER_IMAGE=$(DOCKER_REPO)/$(BINARY)

    unit-test:
	go test ./...

    docker-integration:
	docker-compose build --build-arg VERSION=$(ACTIVE_VERSION)
	docker-compose up --exit-code-from test | grep test_1
	docker-compose push

    docker-push:
	docker pull $(DOCKER_IMAGE):$(shell git rev-parse HEAD)
	docker tag $(DOCKER_IMAGE):$(shell git rev-parse HEAD) $(DOCKER_IMAGE):$(ACTIVE_VERSION)
	docker tag $(DOCKER_IMAGE):$(shell git rev-parse HEAD) $(DOCKER_IMAGE):latest
	docker push  $(DOCKER_IMAGE)

    kubernetes-deployment:
	# Change pods image and label
	kubectl set image \
	deployment/$(shell kubectl get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	date-api=$(DOCKER_IMAGE):$(ACTIVE_VERSION)

	# Re-label oldest deployment and pods
	kubectl label deployment \
	$(shell kubectl get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) \
	"version=${ACTIVE_VERSION}" --overwrite

	kubectl label pods \
	$(shell kubectl get pods -l "name == $(shell kubectl get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})" -o jsonpath={.items[0].metadata.name}) \
	version=${ACTIVE_VERSION} --overwrite

    rollout-wait:
	deployment_wait.sh $(shell kubectl get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})

    promote-deployment:
	kubectl set selector service date-api name=$(shell kubectl get deployments -l "version != $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name}) 

    rollback:
	@read -p "Are you sure you want to rollback deployment $(ACTIVE_VERSION) to $(ROLLBACK_VERSION)? [y/n]:" input; \
	if [ $$input != "y" ]; then printf "%s\n" "Rollback aborted"; exit 0; fi
	@echo "Rolling back $(ACTIVE_VERSION) to $(ROLLBACK_VERSION)"
	kubectl set selector service date-api name=$(shell kubectl get deployments -l "version == $(ROLLBACK_VERSION)" -o jsonpath={.items[0].metadata.name})

