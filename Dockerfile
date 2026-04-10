# syntax=docker/dockerfile:1.7

ARG TARGETPLATFORM

FROM --platform=${TARGETPLATFORM} php:8.4-cli-alpine

LABEL org.opencontainers.image.title="Drupal CS Docker image" \
      org.opencontainers.image.description="Docker image for Drupal code quality, static analysis, refactoring, and CI bootstrap with PHPCS, PHPStan, Drupal Check, Rector, Twig CS Fixer, Composer Normalize, and drupal-cs-init" \
      org.opencontainers.image.vendor="Taras Motuschuk" \
      org.opencontainers.image.authors="Taras Motuschuk" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://hub.docker.com/r/timtom6891/drupal-cs" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/timtom6891/drupal-cs"

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp/composer \
    PATH="/opt/drupal-cs/bin:/opt/drupal-cs/vendor/bin:${PATH}"

RUN apk add --no-cache \
      bash \
      git \
      libxml2-dev \
      oniguruma-dev \
      patch \
      unzip \
    && docker-php-ext-install -j"$(nproc)" mbstring xml \
    && mkdir -p /opt/drupal-cs

WORKDIR /opt/drupal-cs

COPY composer.json /opt/drupal-cs/composer.json
COPY bin /opt/drupal-cs/bin

RUN --mount=type=secret,id=composer_auth,target=/tmp/composer/auth.json \
    composer install --no-interaction --no-progress --prefer-dist \
    && chmod +x /opt/drupal-cs/bin/composer-normalize /opt/drupal-cs/bin/drupal-cs-init /opt/drupal-cs/bin/twigcbf /opt/drupal-cs/bin/twigcs \
    && /opt/drupal-cs/vendor/bin/phpcs --config-set installed_paths \
      ../../drudev/drudev-ccs/src/PHPCS/Standards,../../drupal/coder/coder_sniffer,../../phpcompatibility/php-compatibility,../../sirbrillig/phpcs-variable-analysis,../../slevomat/coding-standard,../../wp-coding-standards/wpcs \
    && ln -sf /opt/drupal-cs/bin/composer-normalize /usr/local/bin/composer-normalize \
    && ln -sf /opt/drupal-cs/bin/drupal-cs-init /usr/local/bin/drupal-cs-init \
    && ln -sf /opt/drupal-cs/bin/twigcs /usr/local/bin/twigcs \
    && ln -sf /opt/drupal-cs/bin/twigcbf /usr/local/bin/twigcbf \
    && ln -sf /opt/drupal-cs/vendor/bin/drupal-check /usr/local/bin/drupal-check \
    && ln -sf /opt/drupal-cs/vendor/bin/phpcbf /usr/local/bin/phpcbf \
    && ln -sf /opt/drupal-cs/vendor/bin/phpcs /usr/local/bin/phpcs \
    && ln -sf /opt/drupal-cs/vendor/bin/phpstan /usr/local/bin/phpstan \
    && ln -sf /opt/drupal-cs/vendor/bin/rector /usr/local/bin/rector \
    && ln -sf /opt/drupal-cs/vendor/bin/twig-cs-fixer /usr/local/bin/twig-cs-fixer \
    && composer clear-cache

WORKDIR /app

CMD ["phpcs", "--version"]
