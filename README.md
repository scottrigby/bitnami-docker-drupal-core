# Supported tags and respective `Dockerfile` links

- [![](https://images.microbadger.com/badges/image/r6by/bitnami-drupal-core:8.6.0-beta2.svg)](https://microbadger.com/images/r6by/bitnami-drupal-core:8.6.0-beta2) [`8.6.0-beta2`, `8.6.0-beta2-r0` (Dockerfile)](https://github.com/scottrigby/bitnami-drupal-core/blob/master/Dockerfile)
- [![](https://images.microbadger.com/badges/image/r6by/bitnami-drupal-core:8.6.0-beta1.svg)](https://microbadger.com/images/r6by/bitnami-drupal-core:8.6.0-beta1) [`8.6.0-beta1`, `8.6.0-beta1-r0` (Dockerfile)](https://github.com/scottrigby/bitnami-drupal-core/blob/master/Dockerfile)
- [![](https://images.microbadger.com/badges/image/r6by/bitnami-drupal-core:8.6.0-alpha1.svg)](https://microbadger.com/images/r6by/bitnami-drupal-core:8.6.0-alpha1) [`8.6.0-alpha1`, `8.6.0-alpha1-r5` (Dockerfile)](https://github.com/scottrigby/bitnami-drupal-core/blob/master/Dockerfile)
- [![](https://images.microbadger.com/badges/image/r6by/bitnami-drupal-core:8.5.6.svg)](https://microbadger.com/images/r6by/bitnami-drupal-core:8.5.6) [`8.5.6`, `8.5.6-r0`, `latest` (Dockerfile)](https://github.com/scottrigby/bitnami-drupal-core/blob/master/Dockerfile)

# What is Bitnami Drupal Core?

Allows specifying Drupal core versions for the [Bitnami Drupal image](https://hub.docker.com/r/bitnami/drupal/).

![Bitnami logo](https://user-images.githubusercontent.com/407675/43671866-f989d24a-976f-11e8-9913-4328ba7e096c.png) ![Docker logo](https://user-images.githubusercontent.com/407675/43671868-fd79f25e-976f-11e8-81f2-60d603dbf2b2.png) ![Drupal logo](https://user-images.githubusercontent.com/407675/43671867-fd6fa218-976f-11e8-8be8-d9a8b2bcfa45.png)

# How to use this image

Follow the [Bitnami Drupal image](https://hub.docker.com/r/bitnami/drupal/) instructions. Whether using the Docker Compose or `docker run` method, swap out `bitnami/drupal:latest` with a `scottrigby/bitnami-drupal-core:TAG` (where TAG is your preferred `DRUPAL_VERSION` above).

Note the Drupal core version tags are mutable (`8.5.6`, `8.6.0-beta2` etc), whereas the versioned image release tags (`DRUPAL_VERSION-r[0-9]` etc) are immutable. If you use the Drupal core version short tags, be sure to follow the [Bitnami upgrade instructions](https://github.com/bitnami/bitnami-docker-drupal#upgrade-this-application) when the corresponding versioned image release tags increment.

In Kubernetes, it's a good idea to use the immutable tag, or set the `imagePullPolicy` to `Always`. If using the [Helm Drupal chart](https://github.com/helm/charts/tree/master/stable/drupal), you can set the [configuration](https://github.com/helm/charts/tree/master/stable/drupal#configuration) directly:
```sh
helm install stable/drupal \
    --set image.repository=scottrigby/bitnami-drupal-core \
    --set image.tag=8.5.6 \
    --set image.pullPolicy=Always
```

# Automation

The images are hosted by [Docker Hub](https://hub.docker.com/r/r6by/bitnami-drupal-core/), and built from versioned image release tags. See [.circleci/config.yml](https://github.com/scottrigby/bitnami-drupal-core/blob/master/.circleci/config.yml) for config details, and the [CircleCI UI](https://circleci.com/gh/scottrigby/bitnami-drupal-core) for build history:

[![CircleCI](https://circleci.com/gh/scottrigby/bitnami-drupal-core.svg?style=svg)](https://circleci.com/gh/scottrigby/bitnami-drupal-core)

# How to build this image manually

See [Drupal 8 core releases](https://www.drupal.org/project/drupal/releases?api_version%5B%5D=7234) for valid release versions.
```sh
docker build \
    --build-arg DRUPAL_VERSION=${DRUPAL_VERSION} \
    --tag ${REGISTRY}/${REPOSITORY}:${DRUPAL_VERSION}
docker push ${REGISTRY}/${REPOSITORY}:${DRUPAL_VERSION}
```
