#!/bin/bash

secode secrets.yaml > secrets_base64.yaml
kubectl apply -f namespace.yaml
kubectl apply -f rbac.yaml -f secrets_base64.yaml -f custom-types.yaml -f postgres.yaml
kubectl apply -f migrations.yaml -f kong.yaml -f ingress-controller.yaml -f ingress.yaml -f admin-ingress.yaml
kubectl -n kong get pods -w