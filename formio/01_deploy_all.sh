#!/bin/bash
kubectl apply -f namespace.yaml
kubectl -n formio create configmap template --from-file=template=1ck.template.json
kubectl -n formio create configmap mg-init-script --from-file=init.js

secode formio-env.yaml > formio-env-base64.yaml
secode mongo-env.yaml > mongo-env-base64.yaml
kubectl apply -f formio-env-base64.yaml -f mongo-env-base64.yaml

kubectl apply -f rbac.yaml -f oidc-plugin.yaml -f request-transformer-plugin.yaml
kubectl apply -f mongo-kubedb.yaml
kubectl apply -f formio.yaml -f ingress.yaml

kubectl -n formio get pods -w