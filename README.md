# ergaleia
[![Build Status](https://secure.travis-ci.org/codem8s/ergaleia.svg?branch=master)](http://travis-ci.org/codem8s/ergaleia)

Kubernetes toolbox in a pod, Sysdig and friends

## Sysdig
To actually run `csysdig`:

    ./docker-entrypoint.sh
    csysdig -k https://kubernetes.default.svc.cluster.local -K /var/run/secrets/kubernetes.io/serviceaccount/token