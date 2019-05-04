# Date API

[![CircleCI](https://circleci.com/gh/srleyva/date-api/tree/master.svg?style=svg)](https://circleci.com/gh/srleyva/date-api/tree/master)

- [x] - Write a web application that returns current date and time in JSON
- [x] - Write a simple client that will test for success/failure/TTLB
- [x] - Perform a blue/green deploy gracefully with no failed requests

## Technologies

### GoLang

I chose the go programming language because of its simplicity, high performance, and scalable nature. Additionally, the ability to compile down to a static binary makes deployments easier.

### Docker/Kubernetes

I chose containers due to their immutable and ephemeral nature. This coupled with Kubernetes and its dynamic service discovery features make an ideal solution in implementing Blue/Green deployments. Additionally, the deployment specs and Dockerfile make the build process repeatable, versioned and automated. This makes the repo the single source of truth for both infrastructure and configuration. Additionally, docker-compose allows me to simulate the prod environment both locally and in the CI process. Kubernetes can run locally via minikube on my machine. This allows me to also test the deployment definitions and promotion logic on my local machine with the same underlying infrastructure as in production.

### Python

I wrote the testing client in Python due to the ease and quickness of testing requests. I could have done this with Go as it works as a scripting language but since this isn't a public facing service, there's no need for the scalability. Python is a powerful yet simple scripting language. It fit my use case for a quick and simple testing client.

---

## How-to

### Deploy a new Build

1. After code changes have been made, bumping the versions in the Makefile will allow for a blue/green deployment.
2. Merge into the master branch
3. The pipeline should take a little less than 2:30 minutes to deploy your change out.

### Rollback a deployment

I am operating on the assumption that a rollback is done in the case of a failure with the new system. Likely services are impacted in such a way that a rollback may be needed ASAP. Therefore this process does not run through a pipeline and manually is performed by an engineer (after its been agreed upon that this is the choice of action).

```bash
$ make rollback
Are you sure you want to rollback deployment 1.7 to 1.6? [y/n]:y
Rolling back 1.7 to 1.6
kubectl set selector service date-api name=date-api-blue -n date-api
Rollback successful
```

### Test the success/failure/TTLB

The utility script takes in 2 arguments:

1. `--host` - the URL (protocol included) of the application
2. `--requests` - the number of requests to send to the endpoint

#### Example

```bash
# Send 100 requests at an AWS loadbalancer
$ python test/test.py --host http://ac511bef66e0511e998b8067c75aff99-897981580.us-east-2.elb.amazonaws.com \
--requests 100
```
