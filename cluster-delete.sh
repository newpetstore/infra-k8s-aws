#!/bin/bash

source env.sh

echo '> > kubectl'
kubectl version --client
echo ''

echo '> > kops'
kops version
echo ''

kops delete cluster --name "${NAME}" --yes
