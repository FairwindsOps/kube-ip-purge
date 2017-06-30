FROM quay.io/reactiveops/kubectl-runner:latest


CMD /bin/bash -c "kubectl config set-cluster currentCluster --server=\"https://${KUBERNETES_SERVICE_HOST}\" && kubectl config set-context currentCluster && kubectl config set-credentials currentCluster --token=\"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\" && kubectl config use-context currentCluster && kubectl exec -it -c weave -n kube-system $(kubectl get pods -n kube-system | grep weave | awk -F ' ' '{print $1}' | head -1 ) -- /bin/sh -c \"curl -s 'http://127.0.0.1:6784/status/ipam' | grep 'unreachable\!$' | sort -k2 -n -r | grep -o '([0-9a-zA-Z\-]*)' | grep -o '[0-9a-zA-Z\-]*' | sed 's/^/127.0.0.1:6784\/peer\//' | xargs curl -X DELETE $1\" && echo 'Done.'"
