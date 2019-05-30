#!/bin/bash

secode keycloak-env.yaml > keycloak-env-base64.yaml
kubectl apply -f keycloak-env-base64.yaml -f kong-ingress-config.yaml -f loopback.yaml -f ingress.yaml
kubectl -n formio get pods -w