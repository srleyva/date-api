FROM alpine

RUN apk add --update make git docker py-pip python-dev libffi-dev openssl-dev gcc libc-dev libgcc py-paramiko

RUN pip install docker-compose awscli

COPY --from=lachlanevenson/k8s-kubectl:v1.10.3 /usr/local/bin/kubectl /usr/local/bin/kubectl
