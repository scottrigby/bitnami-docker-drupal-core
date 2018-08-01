FROM bitnami/drupal:latest

ARG OVERRIDE_VERSION=8.5.6
ENV PACKAGE=drupal \
    ORIGINAL_VERSION=8.5.5-1 \
    OVERRIDE_VERSION=${OVERRIDE_VERSION} \
    DISTRO=debian-9 \
    ARCH=amd64 \
    CACHE_ROOT=/tmp/bitnami/pkg/cache
ENV ORIGINAL_DIR=${PACKAGE}-${ORIGINAL_VERSION}-linux-${ARCH}-${DISTRO} \
    OVERRIDE_FILE=${PACKAGE}-${OVERRIDE_VERSION}
ENV ORIGINAL_URL=https://downloads.bitnami.com/files/stacksmith/${ORIGINAL_DIR}.tar.gz \
    OVERRIDE_URL=https://ftp.drupal.org/files/projects/${OVERRIDE_FILE}.tar.gz \
    OVERRIDE_DIR=${OVERRIDE_FILE}-linux-${ARCH}-${DISTRO}

RUN nami uninstall com.bitnami.drupal \
    && mkdir ${OVERRIDE_DIR} \
    && curl -sS -LOf ${ORIGINAL_URL} \
    && tar xzf ${ORIGINAL_DIR}.tar.gz -C ${OVERRIDE_DIR} --strip-components=1 \
    && rm -r ${OVERRIDE_DIR}/files/drupal && mkdir -p ${OVERRIDE_DIR}/files/drupal \
    && curl -sS -LOf ${OVERRIDE_URL} \
    && tar xzf ${OVERRIDE_FILE}.tar.gz -C ${OVERRIDE_DIR}/files/drupal --strip-components=1 \
    # Bitnami installs drush in drupal/vendor/bin, so replicate that. Drush
    # dependecies require git.
    && apt-get update && apt-get install git -y \
    && cd ${OVERRIDE_DIR}/files/drupal \
    && composer require drush/drush ^9.3 \
    && cd / \
    && touch ${OVERRIDE_DIR}/files/drupal/.buildcomplete \
    && tar -zcf ${OVERRIDE_DIR}.tar.gz ${OVERRIDE_DIR} \
    && mkdir -p ${CACHE_ROOT} \
    && mv ${OVERRIDE_DIR}.tar.gz ${CACHE_ROOT} \
    && ls -lah ${CACHE_ROOT} \
    && bitnami-pkg unpack ${OVERRIDE_FILE}
