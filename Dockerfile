FROM sysdig/sysdig:latest

ENV KUBERNETES_VERSION v1.9.2

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        dnsutils \
        telnet \
        tcpdump \
    && apt-get autoremove -y
    && rm -rf /var/lib/apt/lists/*

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl