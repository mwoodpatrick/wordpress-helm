#!/bin/bash

set -v

. variables.sh

# Upgrade or install application using the current git branch as docker tag
helm delete $releaseName

## Delete remaining PVCs:
kubectl delete pvc \
	data-$releaseName-database-master-0 \
	data-$releaseName-database-slave-0 \
	redis-data-$releaseName-redis-master-0
    redis-data-$releaseName-redis-slave-0
    redis-data-$releaseName-redis-slave-1
