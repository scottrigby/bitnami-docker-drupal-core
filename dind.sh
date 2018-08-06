# !/bin/sh

DRUPAL_VERSION=${1:-8.5.x-dev}
STORAGE_DRIVER=${2:-overlay2}
DIND=${3:-test}
COMPOSE_VERSION=${4:-1.16.1}

docker run \
    --env DRUPAL_VERSION=${DRUPAL_VERSION} \
    --name ${DIND} \
    --privileged \
    --detach \
    docker:dind \
    --storage-driver=${STORAGE_DRIVER}

# Simple technique using docker-compose.
# See https://github.com/docker/compose/blob/master/Dockerfile.s390x
docker exec -it ${DIND} sh -c " \
    apk add --update --no-cache python py-pip curl \
    && pip install --no-cache-dir docker-compose==${COMPOSE_VERSION} \
    && rm -rf /var/cache/apk/* \
    \
    && curl -sSL https://raw.githubusercontent.com/bitnami/bitnami-docker-drupal/master/docker-compose.yml > docker-compose.yml \
    && sed -i 's/bitnami\/drupal:latest/r6by\/bitnami-drupal-core:${DRUPAL_VERSION}/g' docker-compose.yml \
    && docker-compose up -d \
"

docker exec -it ${DIND} sh -c " \
    docker exec -t default_drupal_1 bash -c ' \
	until [ -f /bitnami/drupal/.initialized ]; do \
	    echo Drupal is initializing...; \
        sleep 5; \
	done; \
    echo Drupal has been initialized.' \
"

INSTALLED_VERSION=$(docker exec -it ${DIND} sh -c "
    docker exec -t default_drupal_1 bash -c \" \
        drush -r /opt/bitnami/drupal st | grep 'Drupal version'\ | cut -d' ' -f7 \
    \" \
")

# Clean up before there's a chance to exit.
docker stop ${DIND} && docker rm ${DIND}

# Strip "^M" from variable returned from `docker exec`.
INSTALLED_VERSION=`echo $INSTALLED_VERSION | tr -d '\r'`

# For Drupal "-dev" packages, the "x" is substituted with an integer in the PHP
# "Drupal::VERSION" constant (where drush draws it's version string). The
# integer is not always consistent (examples: "8.7.x-dev" and "8.6.x-dev"
# replace "x" with "0", but "8.5.x-dev" becomes "8.5.7-dev").
# There is only ever one dev package per MINOR version, so check against
# "MAJOR.MINOR.[0-9]-dev" pattern.
REGEX=${DRUPAL_VERSION/x/[0-9]}
# [[ $INSTALLED_VERSION =~ ^$REGEX$ ]] && echo Drupal version ${DRUPAL_VERSION} was successfully installed || Drupal version ${DRUPAL_VERSION} was not successfully installed. Got ${INSTALLED_VERSION}.; exit 1
INSTALLED_VERSION=${INSTALLED_VERSION/0-dev/x-dev}
if [[ $INSTALLED_VERSION =~ ^$REGEX$ ]]; then
    echo "Drupal version ${DRUPAL_VERSION} was successfully installed."
else
    echo "Drupal version ${DRUPAL_VERSION} was not successfully installed. Got ${INSTALLED_VERSION}."
    exit 1
fi
