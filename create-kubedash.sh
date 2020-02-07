kubectl apply \
        -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc3/aio/deploy/recommended.yaml

# To expose the dashboard with public dns
kubectl expose deployment kubernetes-dashboard \
        --type=LoadBalancer \
        --name=kubernetes-dashboard-public \
        -n kubernetes-dashboard

# Ref: https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
# To see the public url
kubectl describe svc kubernetes-dashboard-public \
       -n kubernetes-dashboard

# to serve de dashboard at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
##kubectl proxy

#Reference
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui
