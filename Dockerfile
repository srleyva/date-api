# Build Binary
FROM golang:1.12 as build

ARG VERSION

RUN apt update && apt install -y git tree

RUN mkdir -p "$GOPATH/src/github.com/srleyva/date-api"

WORKDIR $GOPATH/src/github.com/srleyva/date-api

COPY main.go .
COPY Gopkg.* ./
COPY pkg/ ./pkg
COPY vendor/ ./vendor
COPY routes/ ./routes

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.VERSION=$VERSION" -o date-api main.go  && \
     cp date-api /date-api

# Inject Binary into container
FROM scratch
COPY --from=build /date-api /usr/local/bin/date-api
ENTRYPOINT ["/usr/local/bin/date-api"]
