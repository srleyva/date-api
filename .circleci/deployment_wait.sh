#!/bin/sh -e
# This is a blocker to prevent promotion 
# until the new environment has been successfully rolled out
# and new version is available

message() {
    printf "%s\n" "$1"
}

error() {
    printf "%s\n" "$1"
    exit 1
}

attempts=0
limit=10
backoff=1
status="kubectl rollout status deployment/$1"

until $status || [ $attempts -eq $limit ]; do
    $status
    attempts=$((attempts + 1))
    message "rollout not ready..retry after $backoff seconds"
    sleep $backoff
    backoff=$((backoff * 2))
done

if [ $attempts -eq $limit ]; then
    error "The deployment has not successfully rolled out"
fi

message "Deployment Successful...promoting build"
