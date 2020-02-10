# Kubernetes Infrastructure at AWS

To create kubernetes cluster at AWS

## How to Use

- Install [kops](https://github.com/kubernetes/kops) 1.15.1
  - For detailed usage, [this tutorial](https://github.com/kubernetes/kops/blob/master/docs/getting_started/aws.md)
 to use kops with AWS
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
1.17.0
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

- Execute the command bellow:
```bash
helm install grafana helm/grafana
```

### To access the grafana web console

- Get the admin password

```bash
kubectl get secret \
        --namespace default grafana \
        -o jsonpath="{.data.admin-password}" \
        | base64 --decode ; echo
```

- Start the port forwarding

```bash
# Export the pod name
export POD_NAME=$(kubectl get pods --namespace default -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")

# Start the port forwarding
kubectl --namespace default port-forward $POD_NAME 3000
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

## To destroy the cluster

- Execute the `cluster-delete.sh`
```bash
./cluster-delete.sh
```
