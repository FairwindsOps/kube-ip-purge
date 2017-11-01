#!/bin/bash
set -e

kubectl config set-cluster currentCluster --server=\"https://${KUBERNETES_SERVICE_HOST}\"
kubectl config set-context currentCluster
kubectl config set-credentials currentCluster --token=\"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\"
kubectl config use-context currentCluster

while true
do
  touch /lastloop
  weave_pod=$(kubectl get pods -n kube-system | grep weave | awk -F ' ' '{print $1}' | shuf | head -1 )
  echo "Using ${weave_pod}..."
  [[ -n ${weave_pod} ]]
  node_regex=$(kubectl get nodes --no-headers -o=custom-columns=NAME:.metadata.name | sed -E "s/ip-(.*)\.ec2.*/\1$|\1.ec2/" | paste -d '|' -s -)
  kubectl exec -i -c weave -n kube-system ${weave_pod} -- /bin/sh -c \
    'curl -s http://127.0.0.1:6784/status/ipam | \
    grep unreachable\\!$ | \
    sed -E "s/.*\(ip-([0-9-]+).*/127.0.0.1:6784\/peer\/ip-\1\n127.0.0.1:6784\/peer\/ip-\1.ec2.internal/" | \
    sort | \
    uniq | grep -Ev "('"${node_regex}"')" | \
    echo "127.0.0.1:6784/peer/minimumOneHost
    $(cat -)" | \
    xargs -n 1 curl -sX DELETE'
  echo "Done."
  touch /lastloop
  sleep 120
done
