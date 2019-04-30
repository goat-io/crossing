
# Goat Crossing

<p align="center">
  <img src="https://www.picclickimg.com/d/l400/pict/221946948940_/GOAT-XING-Funny-Novelty-Crossing-Sign.jpg"/>
</p>

Entrypoint and access control for easy API and user control management. Based on Kong and OIDC-based authentication (with Keycloak as a provider), this application provides an easy to use starter development template for new APIs in a Kubernetes managed cluster.

## Deployment

Assuming a Kubernetes cluster is already up and running, follow these steps to configure Goat Crossing:

:goat: tip: this has only been tested in Google Kubernetes Engine, but it should work in a local (minikube) or different (AWS/Azure) environment. :goat:

:goat: tip: default secret files are provided in both folders. To create secrets in Kubernetes, we need to encode the values from plain text to base64. We recommend this [plugin](https://github.com/crtomirmajer/secode) to easily encode these files.

### Create app namespaces

```
kubectl apply -f kong/namespace.yaml
kubectl apply -f keycloak/namespace.yaml
```

### Private image secret

To configure OIDC for Kong, [this plugin](https://github.com/nokia/kong-oidc) has been installed on top of the default Kong Docker image. This image has already been built on this [private repo](https://gitlab.com/goatlab/corporate/kong-oidc) by us, so you'll need to configure a secret with the access token for the Gitlab registry.

```
docker login
```
```
kubectl -n kong create secret generic regcred \
    --from-file=.dockerconfigjson=~/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

### Helm configuration

We will need Helm for the next step, so [configure](https://cloud.google.com/community/tutorials/nginx-ingress-gke#install_helm_in_cloud_shell) it before moving on to the next step.

```
curl -o get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
chmod +x get_helm.sh
./get_helm.sh
rm get_helm.sh
```

```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
```

### Nginx Ingress for Keycloak

We will be using two different Ingress types for our applications: Kong Ingress for our protected APIs and a standard Nginx Ingress Controller to serve our public Keycloak login and register pages.

Edit the keycloak/ingress-config.yaml file to set up the Ingress the way you want. The most important setting is the controller.service.LoadBalancerIP, which should point towards one of your two available static IP addresses.

```
helm install --namespace keycloak --name nginx-ingress \
    stable/nginx-ingress -f keycloak/ingress-config.yaml
```

<a name="install-keycloak"></a> 
### Install Keycloak

Now that Nginx Ingress is configured, we can install Keycloak and its resources.

Edit keycloak/ingress.yaml to change both spec.tls.hosts and spec.rules-hosts to point towards your registered host (or nip.io wildcard with your static IP address set in the previous step).

```
kubectl apply -f keycloak/secrets_base64.yaml && \
    kubectl apply -f keycloak/postgres.yaml && \
    kubectl apply -f keycloak/keycloak.yaml && \
    kubectl apply -f keycloak/ingress.yaml
```

### Install Kong

Now, we can install our private Kong+OIDC image and set our Ingress to serve our application.

Edit kong/ingress-load-balancer.yaml service.spec.loadBalancerIP to point towards your second static IP address. This IP address will serve all applications protected by Kong.

**(Optional: Set url for Kong Admin API)** Edit kong/admin-ingress.yaml spec.rules.host to point towards your admin url (or nip.io wildcard with the second static IP address).

```
kubectl apply -f kong/secrets_base64.yaml && \
    kubectl apply -f kong/custom-types.yaml && \
    kubectl apply -f kong/rbac.yaml && \
    kubectl apply -f kong/postgres.yaml && \
    kubectl apply -f kong/migrations.yaml && \
    kubectl apply -f kong/kong.yaml && \
    kubectl apply -f kong/ingress-load-balancer.yaml && \
    kubectl apply -f kong/kong-admin.yaml && \
    kubectl apply -f kong/admin-ingress.yaml && \
```

### Set up Keycloak

*Todo: automatic configuration through json file*

Login to Keycloak via the address you set [here](#install-keycloak). Your credentials are the ones set on keycloak/secrets_base64.yaml (admin/admin by default).

Set up a new realm and create a client. Set access type to confidential and set the root url + valid redirect uris of your applications. Take note of the secret in the credentials tab, as this value is needed to deploy applications.

Create a user and set its credentials in the realm you created.

### (Optional) Test your configuration with a dummy app

A dummy app is included in this repository to test if your configuration works.

Edit dummy/oidc-plugin.yaml with your Keycloak information and set up your Ingress file at dummy/ingress.yaml.

```
kubectl apply -f dummy/namespace.yaml && \
    kubectl apply -f dummy/rate-limiting-plugin.yaml && \
    kubectl apply -f dummy/oidc-plugin.yaml && \
    kubectl apply -f dummy/dummy-app.yaml && \
    kubectl apply -f dummy/ingress.yaml && \
```

After a few moments, you should be able to go into your url and path defined in your Ingress file. It should redirect you towards the Keycloak login page. After logging in with the user you created, it will redirect you to the dummy app. Magic!

## Adding new APIs

Now that Goat Crossing is configured, adding new API routes and paths is easy as pie! :pie:

All new apps follow the same guidelines:
* Its own namespace
* Deployment
* Service, exposed by NodePort
* Kong Ingress
* (optional) Any extra Kong plugins you might add

Plugins can be added at Ingress (via path) or Service level.