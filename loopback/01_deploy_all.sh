#!/bin/bash

kubectl apply -f kong-ingress-config.yaml -f loopback.yaml -f ingress.yaml
kubectl -n formio get pods -w