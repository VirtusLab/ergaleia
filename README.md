# ergaleia
![Version](https://img.shields.io/badge/version-v0.0.2-brightgreen.svg)
[![Build Status](https://secure.travis-ci.org/codem8s/ergaleia.svg?branch=master)](http://travis-ci.org/codem8s/ergaleia)
[![Docker Repository on Quay.io](https://quay.io/repository/codem8s/ergaleia/status "Docker Repository on Quay.io")](https://quay.io/repository/codem8s/ergaleia)

Kubernetes toolbox in a pod, with [Sysdig](https://github.com/draios/sysdig) and friends

## Installation and Usage

    kubectl apply -f https://raw.githubusercontent.com/codem8s/ergaleia/master/kubernetes/ergaleia.yaml
    kubectl exec -n toolbox -it ergaleia-0

    docker pull quay.io/codem8s/ergaleia:v0.0.2
    docker run quay.io/codem8s/ergaleia:v0.0.2

### Sysdig

To run `csysdig` with Kubernetes access:

    csysdig -k https://kubernetes.default.svc.cluster.local -K /var/run/secrets/kubernetes.io/serviceaccount/token
    
### kubectl

The command will get it's credentials from the service token, no special configuration needed:

    kubectl version

## Packages and binaries

The image is based on Debian, so if there's anything missing just use `apt`.

Most important pre-installed commands:
- `sysdig` and `csysdig`
- `kubectl`
- `docker`

Other selected pre-installed commands:
- `curl`
- `gcc`
- `less`
- `dig` and `nslookup`
- `telnet`
- `tcpdump`
- `traceroute`