FROM quay.io/reactiveops/kubectl-runner:latest

RUN apk --no-cache add coreutils

ADD run.sh ./
CMD ["bash", "run.sh"]
