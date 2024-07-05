#!/bin/bash

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/bootstrap -ldflags '-w' main.go

zip -j build/bootstrap.zip build/bootstrap

cd terraform

terraform init

terraform apply
