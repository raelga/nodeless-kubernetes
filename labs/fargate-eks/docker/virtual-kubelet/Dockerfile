FROM golang:1.13.1-alpine3.10 AS build-env
RUN apk add git alpine-sdk bash
RUN mkdir -p $GOPATH/src/github.com/virtual-kubelet && \
    cd $GOPATH/src/github.com/virtual-kubelet && \
    git clone https://github.com/virtual-kubelet/virtual-kubelet && \
    cd virtual-kubelet && \
    git checkout v0.9.1 && \
    make build && \
    mv bin/virtual-kubelet /usr/bin/

FROM golang:1.13.1-alpine3.10
RUN apk add python py-pip
RUN pip install awscli
RUN wget -O /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
COPY --from=build-env /usr/bin/virtual-kubelet /usr/bin/virtual-kubelet
COPY fargate.toml /
COPY docker-entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/docker-entrypoint.sh /usr/bin/virtual-kubelet /usr/bin/aws-iam-authenticator

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["virtual-kubelet", "--provider", "aws", "--provider-config", "/fargate.toml", "--kubeconfig", "/root/.kube/config"]