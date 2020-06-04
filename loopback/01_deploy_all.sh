#!/bin/bash

secode keycloak-env.yaml > keycloak-env-base64.yaml
secode pusher-env.yaml > pusher-env-base64.yaml
kubectl apply -f pusher-env-base64.yaml -f keycloak-env-base64.yaml -f kong-ingress-config.yaml -f oidc-plugin.yaml -f loopback.yaml -f ingress.yaml
kubectl -n formio get pods -w