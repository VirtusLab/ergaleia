# ergaleia
[![Version](https://img.shields.io/badge/version-v0.0.4-brightgreen.svg)](https://quay.io/VirtusLab/ergaleia:v0.0.4)
[![Docker Repository on Quay.io](https://quay.io/repository/VirtusLab/ergaleia/status "Docker Repository on Quay.io")](https://quay.io/repository/VirtusLab/ergaleia)

Kubernetes toolbox in a pod, with [Sysdig](https://github.com/draios/sysdig) and friends

## Installation and Usage

    kubectl apply -f https://raw.githubusercontent.com/VirtusLab/ergaleia/master/kubernetes/ergaleia.yaml
    kubectl exec -n toolbox -it ergaleia-0

    docker pull quay.io/VirtusLab/ergaleia:v0.0.4
    docker run quay.io/VirtusLab/ergaleia:v0.0.4

### Sysdig

To run `csysdig` with a Kubernetes service token, here's an alias:

    ksysdig
    
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
- `vim`
- `curl`
- `gcc`
- `less`
- `dig` and `nslookup`
- `telnet`
- `tcpdump`
- `traceroute`
