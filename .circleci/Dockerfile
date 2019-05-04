FROM alpine

RUN apk add --update make git docker py-pip python-dev libffi-dev openssl-dev gcc libc-dev libgcc py-paramiko curl

RUN pip install docker-compose awscli

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator && \
  chmod +x ./aws-iam-authenticator && \
  mv aws-iam-authenticator /usr/local/bin

COPY --from=lachlanevenson/k8s-kubectl:v1.10.3 /usr/local/bin/kubectl /usr/local/bin/kubectl
