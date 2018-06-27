# ergaleia
[![Version](https://img.shields.io/badge/version-v0.0.8-brightgreen.svg)](https://quay.io/virtuslab/ergaleia:v0.0.8)
[![Build Status](https://secure.travis-ci.org/VirtusLab/ergaleia.svg?branch=master)](http://travis-ci.org/VirtusLab/ergaleia)


Kubernetes toolbox in a pod, with [Sysdig](https://github.com/draios/sysdig) and friends

## Installation and Usage

    kubectl apply -f https://raw.githubusercontent.com/virtuslab/ergaleia/master/kubernetes/ergaleia.yaml
    kubectl exec -n toolbox -it ergaleia-0 bash

Note: to use with PodSecurityPolicy you need to provide a `priviledged` policy and role shown in [privileged-psp.yaml](kubernetes/privileged-psp.yaml)

## Removal

When you are done with `ergaleia` you the best way to remove it is be running:

    kubectl delete -f https://raw.githubusercontent.com/virtuslab/ergaleia/master/kubernetes/ergaleia.yaml

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
- `tracepath`
- `nmap`