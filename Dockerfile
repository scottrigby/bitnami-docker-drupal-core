# Multistep Dockerfile to keep final build as light as possible extension of
# https://github.com/bitnami/bitnami-docker-drupal.
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
RUN apk add --no-cache libpng libpng-dev \
    && docker-php-ext-install gd \
    && apk del libpng-dev
# Drush dependencies require git.
RUN apk --no-cache add git \
    && mkdir ${OVERRIDE_DIR} \
    # Get the original package defined in bitnami/drupal:latest image, and
    # unpack into a directory with our new bitnami package name.
    && curl -sS -LOf ${ORIGINAL_URL} \
    && tar xzf ${ORIGINAL_DIR}.tar.gz -C ${OVERRIDE_DIR} --strip-components=1 \
    # Remove Druapl core files while retaining the rest of the nami drupal
    # package structure. Also add an empty files dir (more future-proof than rm
    # specified dotfiles, which may differ between core versions).
    && rm -r ${OVERRIDE_DIR}/files/drupal && mkdir -p ${OVERRIDE_DIR}/files/drupal \
    # Unpack new DRUPAL_VERSION files to replace the former version.
    && curl -sS -LOf ${OVERRIDE_URL} \
    && tar xzf ${OVERRIDE_FILE}.tar.gz -C ${OVERRIDE_DIR}/files/drupal --strip-components=1 \
    # Bitnami installs drush in drupal/vendor/bin, so we must require from
    # Drupal root, then return back.
    && cd ${OVERRIDE_DIR}/files/drupal \
    && composer require drush/drush ^9.3 \
    && cd - \
    # Replicate Bitnami build completion indicator.
    && touch ${OVERRIDE_DIR}/files/drupal/.buildcomplete \
    && tar -zcf ${OVERRIDE_DIR}.tar.gz ${OVERRIDE_DIR} \
    # Stash built nami package with user-specified DRUPAL_VERSION.
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
# Fetch drupal nami package from Docker build step, and place into the
# CACHE_ROOT. If a package is in the CACHE_ROOT, "bitnami-pkg unpack" will skip
# downloading from Bitnami's release bucket.
# See https://github.com/bitnami/minideb-extras/blob/master/stretch/rootfs/usr/local/bin/bitnami-pkg#L138
COPY --from=build /tmp/${OVERRIDE_DIR}.tar.gz ${CACHE_ROOT}/${OVERRIDE_DIR}.tar.gz
# We first delete the original package before installing our own, otherwise
# the nami drupal package installer will complain that Drupal is already
# partially installed.
RUN nami uninstall com.bitnami.drupal \
    && bitnami-pkg unpack ${OVERRIDE_FILE}
