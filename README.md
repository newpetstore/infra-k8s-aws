# Kubernetes Infrastructure at AWS

To create kubernetes cluster at AWS

## How to Use

- Install [kops](https://github.com/kubernetes/kops) 1.8+
  - For detailed usage, [this tutorial](https://github.com/kubernetes/kops/blob/master/docs/getting_started/aws.md)
 to use kops with AWS
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
1.11+
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

- Export your `ZONES` where kubernetes cluster will be created
```bash
# Ohio, for example
export ZONES='us-east-2a'
```

- Export your `NAME`, that will be the cluster name
```bash
# Use .k8s.local suffix, telling to kops to create a gossip-based cluster
export NAME='pets.k8s.local'
```
- Create a S3 bucket to store kops state
  - If are familiar with Terraform, [use this](./terraform) to create the bucket
- Export the S3 bucket name created above
```bash
export KOPS_STATE_STORE='s3://YOUR BUCKET NAME'
```

- Execute the `cluster-create.sh` script
```bash
./cluster-create.sh
```

## To create kubernetes dashboard

- Execute the `create-kubedash.sh` script
```bash
./create-kubedash.sh
```

## To create an admin user

You should use this account to login at kubernetes dashboard.

- Execute the `create-admin.sh`
```bash
./create-admin.sh
```

## To destroy the cluster

- Export the same environment variables
- Execute the `cluster-delete.sh`
```bash
./cluster-delete.sh
```
