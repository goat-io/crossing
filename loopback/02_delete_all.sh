#!/bin/bash

kubectl delete -f kong-ingress-config.yaml -f loopback.yaml -f ingress.yaml