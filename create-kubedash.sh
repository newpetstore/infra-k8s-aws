kubectl create \
       -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.3.yaml

# To expose the dashboard with public dns
kubectl expose deployment kubernetes-dashboard \
        --type=LoadBalancer \
        --name=kube-dash \
        -n kube-system

# Ref: https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
# To see the public url
kubectl describe svc kube-dash -n kube-system

#kubectl get svc -n kube-system

# to serve de dashboard at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
##kubectl proxy

#Reference
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui
