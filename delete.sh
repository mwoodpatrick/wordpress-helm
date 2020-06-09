#!/bin/bash

set -v

. variables.sh

# Upgrade or install application using the current git branch as docker tag
helm delete $releaseName

## Delete remaining PVCs:
kubectl delete pvc data-$releaseName-mariadb-master-0 data-$releaseName-mariadb-slave-0 data-$releaseName-database-0 redis-data-$releaseName-redis-master-0

