#!/bin/bash

kubectl delete -f migrations.yaml -f kong.yaml -f ingress-controller.yaml -f ingress.yaml -f admin-ingress.yaml
kubectl delete -f rbac.yaml -f secrets_base64.yaml -f custom-types.yaml -f postgres.yaml
kubectl delete -f namespace.yaml