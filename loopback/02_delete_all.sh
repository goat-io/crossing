#!/bin/bash

kubectl delete -f pusher-env-base64.yaml -f keycloak-env-base64.yaml -f kong-ingress-config.yaml -f loopback.yaml -f ingress.yaml