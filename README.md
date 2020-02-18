# Kubernetes Infrastructure at AWS

To create kubernetes cluster at AWS

## How to Use

- Install [kops](https://github.com/kubernetes/kops) 1.15.1
  - For detailed usage, [this tutorial](https://github.com/kubernetes/kops/blob/master/docs/getting_started/aws.md)
 to use kops with AWS
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
1.17.0
  - You may use [kubectl aliases](https://github.com/ahmetb/kubectl-aliases)
- Install [helm](https://helm.sh/docs/intro/install/) 3.0.3
- Create a ssh keypair
  - kops use the `~/.ssh/id_rsa.pub`, by default
- Create an account with these IAM permissions:
```txt
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
```

- Export your `AWS_ACCESS_KEY_ID`
```bash
export AWS_ACCESS_KEY_ID='<YOUR ACCESS KEY>'
```

- Export your `AWS_SECRET_ACCESS_KEY`
```bash
export AWS_SECRET_ACCESS_KEY='<YOUR SECRET KEY>'
```

- Create a S3 bucket to store kops state
  - If are familiar with Terraform, [use this](./terraform) to create the bucket

- Edit the `env.sh` script and set the following variables
```bash
# Ohio, for example
export ZONES='us-east-2a'
# Use .k8s.local suffix, telling to kops to create a gossip-based cluster
export NAME='pets.k8s.local'
export KOPS_STATE_STORE='s3://YOUR BUCKET NAME'
```

- Execute the `cluster-create.sh` script
```bash
./cluster-create.sh
```
- Wait until the cluster is ready to create the resources ahead

- To see cluster status
```bash
kubectl get nodes
```

You can go ahead when every node is `Ready`:
```bash
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-20-37-9.us-east-2.compute.internal     Ready    master   29m   v1.15.9
ip-172-20-46-165.us-east-2.compute.internal   Ready    node     28m   v1.15.9
ip-172-20-54-151.us-east-2.compute.internal   Ready    node     28m   v1.15.9
```

## To edit kubelet configuration

> Checkout [these details](https://github.com/kubernetes/kops/blob/master/docs/changing_configuration.md)

- Open the cluster configuration
```bash
source env.sh
kops edit cluster
```

- Edit the kubelet spec, to add `authenticationTokenWebhook` and
`authorizationMode`
```yaml
kind: Cluster
metadata:
  name: xxx.xxx.com
spec:
  # ...
  kubelet:
    anonymousAuth: false
    authenticationTokenWebhook: true
    authorizationMode: Webhook
```

- Update the cluster
```bash
kops update cluster --yes
kops rolling-update cluster --yes
```

## To create the metrics server

The metrics server provide data for [horizontal pod autoscale](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/).

```bash
helm install --namespace=kube-system \
     metrics-server helm/metrics-server
```

## To create kubernetes dashboard

- Execute the `create-kubedash.sh` script
```bash
./create-kubedash.sh
```

- After few seconds, execute command bellow to get the public DNS of that dashboard
```bash
kubectl describe svc \
        kubernetes-dashboard-public \
       -n kubernetes-dashboard
```

## To create an admin user

You should use this account to login at kubernetes dashboard.

- Execute the `create-admin.sh`
```bash
./create-admin.sh
```

## To deploy the Prometheus

- Execute the command bellow:
```bash
helm install prometheus helm/prometheus
```

- The Prometheus's server URL will be: `http://prometheus-server.default.svc.cluster.local`

### To access the prometheus web console

```bash
# Export the pod name
export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")

# Start the port forwarding
kubectl --namespace default port-forward $POD_NAME 9090
```

## To deploy the Grafana

- Add the bitnami helm charts repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

- Execute the command bellow:
```bash
helm install grafana bitnami/grafana
```

### To access the grafana web console

- Get the admin password
```bash
kubectl get secret grafana-secret \
        --namespace default \
        -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode
```

- Expose grafana with a public DNS
```bash
kubectl expose service grafana \
      --type=LoadBalancer \
      --name=grafana-public \
      -n default
```

- And get that public DNS
```bash
kubectl describe svc \
      grafana-public \
     -n default
```

## To deploy EFK Stack

- Add the elastic helm charts repository
```bash
helm repo add elastic https://helm.elastic.co
```

- Install the Elasticsearch [(details)](https://github.com/elastic/helm-charts/tree/7.5.2/elasticsearch):
```bash
helm install elasticsearch elastic/elasticsearch --version 7.5.2
```

- Install the Filebeat [(details)](https://github.com/elastic/helm-charts/tree/7.5.2/filebeat):
```bash
helm install filebeat elastic/filebeat --version 7.5.2
```

- Install the Kibana [(details)](https://github.com/elastic/helm-charts/tree/7.5.2/kibana):
```bash
helm install kibana elastic/kibana --version 7.5.2
```

- Expose the Kibana with public DNS:
```bash
kubectl expose deployment kibana-kibana \
        --type=LoadBalancer \
        --name=kibana-public \
        -n default
```

- After few seconds, execute command bellow to get the public DNS of Kibana
```bash
kubectl describe svc kibana-public -n default
```

## Create namespaces for your projects

```bash
kubectl create namespace 'a-namespace'
```

## To deploy a mongodb instance

- Execute the command bellow:
```bash
helm install --namespace='a-namespace' mongodb helm/mongodb
```

- Get the root password
```bash
kubectl get secret \
        --namespace='a-namespace' \
        mongodb \
        -o jsonpath="{.data.mongodb-root-password}" \
        | base64 --decode
```

## To deploy the istio

- Install [istioctl](https://github.com/istio/istio/releases/download/1.4.3/istioctl-1.4.3-linux.tar.gz) 1.4.3
  - Get [more details](https://istio.io/docs/setup/getting-started/)

- Deploy the istio, running this command:
```bash
istioctl manifest apply --set profile=demo
```

## To destroy the cluster

- Execute the `cluster-delete.sh`
```bash
./cluster-delete.sh
```
