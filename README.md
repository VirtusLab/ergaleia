# ergaleia
![Version](https://img.shields.io/badge/version-v0.0.1-brightgreen.svg)
[![Build Status](https://secure.travis-ci.org/codem8s/ergaleia.svg?branch=master)](http://travis-ci.org/codem8s/ergaleia)
[![Docker Repository on Quay.io](https://quay.io/repository/codem8s/ergaleia/status "Docker Repository on Quay.io")](https://quay.io/repository/codem8s/ergaleia)

Kubernetes toolbox in a pod, Sysdig and friends

## Sysdig
To actually run `csysdig`:

    ./docker-entrypoint.sh
    csysdig -k https://kubernetes.default.svc.cluster.local -K /var/run/secrets/kubernetes.io/serviceaccount/token
