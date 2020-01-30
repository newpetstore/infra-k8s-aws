#!/bin/bash

source env.sh

echo '> > kubectl'
kubectl version --client
echo ''

echo '> > kops'
kops version
echo ''

kops create cluster --zones ${ZONES} ${NAME}

kops update cluster ${NAME} --yes
