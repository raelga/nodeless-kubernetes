FROM traefik:v2.0.2
# RUN apk add git alpine-sdk bash
# RUN cd / && curl -L https://github.com/containous/traefik/releases/download/v2.0.2/traefik_v2.0.2_linux_amd64.tar.gz | tar xvz
# COPY script/ca-certificates.crt /etc/ssl/certs/
# COPY dist/traefik /
# RUN mkdir -p /var/run/secrets/kubernetes.io/serviceaccount
COPY ca.crt /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
COPY token /var/run/secrets/kubernetes.io/serviceaccount/token
# EXPOSE 80
# VOLUME ["/tmp"]
# ENTRYPOINT ["/traefik"]