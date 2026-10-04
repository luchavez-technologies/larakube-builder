# Builder for `larakube new` (Laravel) and `larakube statamic:new`: the Server Side Up image the
# deployed app uses, with Node, npm, Bun and the global Composer tools already installed, so a new
# project does not install them on every run.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG COMPOSER_GLOBAL
ENV COMPOSER_ALLOW_SUPERUSER=1

USER root
RUN apk add --no-cache nodejs npm git unzip \
    && npm install -g bun \
    && composer config -g bin-dir /usr/local/bin \
    && composer global require ${COMPOSER_GLOBAL} \
    && composer clear-cache
