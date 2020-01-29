kubectl create \
       -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.3.yaml

# To expose the dashboard??
kubectl expose deployment kubernetes-dashboard --type=LoadBalancer --name=kube-dash -n kube-system

# Ref: https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
# To see the public url
kubectl get svc -n kube-system
kubectl describe svc kube-dash -n kube-system

kubectl create -f admin.user.yml
kubectl create -f admin.user.role.yml

# to get the token for the user above
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

# to get the token
kops get secrets kube --type secret -oplaintext

# to serve de dashboard at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
kubectl proxy

#Reference
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui
