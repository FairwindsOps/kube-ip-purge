FROM quay.io/reactiveops/kubectl-runner:latest

ADD run.sh ./
CMD ["bash","run.sh"]
