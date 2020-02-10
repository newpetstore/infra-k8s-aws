#!/bin/bash

kubectl create -f admin.user.yml
kubectl create -f admin.user.role.yml

# to get the token for the user above
kubectl -n kube-system describe secret \
        $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

# to get the token
kops get secrets kube --type secret -oplaintext
