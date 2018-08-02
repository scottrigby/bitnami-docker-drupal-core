FROM composer:latest as build
ARG DRUPAL_VERSION
ENV DRUPAL_VERSION=${DRUPAL_VERSION:-8.5.6} \
    PACKAGE=drupal \
    ORIGINAL_VERSION=8.5.5-1 \
    DISTRO=debian-9 \
    ARCH=amd64
ENV ORIGINAL_DIR=${PACKAGE}-${ORIGINAL_VERSION}-linux-${ARCH}-${DISTRO} \
    OVERRIDE_FILE=${PACKAGE}-${DRUPAL_VERSION}
ENV ORIGINAL_URL=https://downloads.bitnami.com/files/stacksmith/${ORIGINAL_DIR}.tar.gz \
    OVERRIDE_URL=https://ftp.drupal.org/files/projects/${OVERRIDE_FILE}.tar.gz \
    OVERRIDE_DIR=${OVERRIDE_FILE}-linux-${ARCH}-${DISTRO}
# Drush dependencies require PHP's gd extension.
RUN apk add --no-cache libpng libpng-dev && docker-php-ext-install gd && apk del libpng-dev
# Drush dependencies require git.
RUN apk --no-cache add git \
    && mkdir ${OVERRIDE_DIR} \
    && curl -sS -LOf ${ORIGINAL_URL} \
    && tar xzf ${ORIGINAL_DIR}.tar.gz -C ${OVERRIDE_DIR} --strip-components=1 \
    && rm -r ${OVERRIDE_DIR}/files/drupal && mkdir -p ${OVERRIDE_DIR}/files/drupal \
    && curl -sS -LOf ${OVERRIDE_URL} \
    && tar xzf ${OVERRIDE_FILE}.tar.gz -C ${OVERRIDE_DIR}/files/drupal --strip-components=1 \
    # Bitnami installs drush in drupal/vendor/bin.
    && cd ${OVERRIDE_DIR}/files/drupal \
    && composer require drush/drush ^9.3 \
    && cd - \
    && touch ${OVERRIDE_DIR}/files/drupal/.buildcomplete \
    && tar -zcf ${OVERRIDE_DIR}.tar.gz ${OVERRIDE_DIR} \
    && mv ${OVERRIDE_DIR}.tar.gz /tmp/

FROM bitnami/drupal:latest
ARG DRUPAL_VERSION
ENV DRUPAL_VERSION=${DRUPAL_VERSION:-8.5.6} \
    PACKAGE=drupal \
    DISTRO=debian-9 \
    ARCH=amd64 \
    CACHE_ROOT=/tmp/bitnami/pkg/cache
ENV OVERRIDE_FILE=${PACKAGE}-${DRUPAL_VERSION}
ENV OVERRIDE_DIR=${OVERRIDE_FILE}-linux-${ARCH}-${DISTRO}
COPY --from=build /tmp/${OVERRIDE_DIR}.tar.gz ${CACHE_ROOT}/${OVERRIDE_DIR}.tar.gz
RUN nami uninstall com.bitnami.drupal \
    && bitnami-pkg unpack ${OVERRIDE_FILE}
