# Drupal CS Docker Image for PHP 8.4

Docker image for Drupal code quality, `docker drupal-cs`, and `docker drupal-phpcs` workflows on PHP 8.4.
It is built for local QA, CI runners, and starter config generation for Drupal projects.

Links:

- Docker Hub: <https://hub.docker.com/repository/docker/timtom6891/drupal-cs/general>
- GitHub: <https://github.com/TarasMotuschuk/drupal-cs>

The image packages Drupal-focused CLI tools in a single container:

- `phpcs` / `phpcbf`
- `drupal-check`
- `phpstan`
- `rector`
- `twigcs` / `twigcbf`
- `composer-normalize`
- `drupal-cs-init`

## Overview

Typical use cases:

- run Drupal code quality checks locally without installing tools on the host
- bootstrap starter configs for custom Drupal modules and themes
- generate CI pipeline templates for Bitbucket, GitHub Actions, and GitLab
- standardize QA tooling across multiple Drupal projects

## Commands At A Glance

| Command | Purpose |
| --- | --- |
| `phpcs` | Check Drupal coding standards violations |
| `phpcbf` | Auto-fix PHPCS-fixable violations |
| `drupal-check` | Detect Drupal-specific deprecations and static analysis issues |
| `phpstan` | Run general static analysis |
| `rector` | Apply automated refactoring rules |
| `twigcs` | Lint Twig templates |
| `twigcbf` | Auto-fix supported Twig style issues |
| `composer-normalize` | Normalize `composer.json` formatting |
| `drupal-cs-init` | Generate baseline configs and optional CI pipelines |

## Pull

```bash
docker pull timtom6891/drupal-cs:latest
```

If you plan to use this image in Bitbucket Pipelines or other Linux/X86_64 hosted CI runners, publish an `amd64`-compatible image or a multi-arch manifest. A locally pushed Apple Silicon image can otherwise fail to start on hosted runners.

## Basic usage

```bash
docker run --rm timtom6891/drupal-cs:latest
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpcs --standard=Drupal,DrupalPractice web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpcbf --standard=Drupal web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-check web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpstan analyse web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest rector process web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest twigcs
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest twigcbf
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest composer-normalize
```

## Config And Pipeline Generation (`drupal-cs-init`)

The image includes a built-in `drupal-cs-init` command that bootstraps baseline static-analysis configs and optional CI pipeline templates for a Drupal project.

Generated config files:

- `phpcs.xml`
- `.twig-cs-fixer.php`
- `phpstan.neon.dist`
- `rector.php`

Default behavior:

- writes files to the current working directory
- skips files that already exist
- creates `tmp/` in the target directory

Use `--force` to overwrite existing files.

Available presets:

- `basic` is the default and generates a generic Drupal-oriented starter config
- `drudev` is a backward-compatible alias for the strict Drudev/Drupal PHPCS starter
- `drupal-low` generates a light Drupal PHPCS baseline
- `drupal-base` generates a Drupal PHPCS baseline with `DrupalPractice`
- `drupal-strict` generates a strict Drupal PHPCS baseline
- `drupal7`, `drupal8`, `drupal9`, and `drupal10` generate version-aware Drupal PHPCS baselines with PHP compatibility checks

Supported options:

- `--preset=basic|drudev|drupal-low|drupal-base|drupal-strict|drupal7|drupal8|drupal9|drupal10`
- `--ci=all|bitbucket,github,gitlab`
- `--target-dir=PATH`
- positional target dir (`drupal-cs-init some/path`)
- `--force`
- `--help`

Examples:

```bash
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --preset=drudev
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --preset=drupal-base
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --preset=drupal10
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --ci=all
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --ci=github,gitlab
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --target-dir=web/modules/custom/example_module
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init web/modules/custom/example_module
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --force
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init --help
```

Generated pipelines use `timtom6891/drupal-cs:latest` and support:

- Bitbucket Pipelines
- GitHub Actions
- GitLab CI

## Integration examples

### Lando

Example `.lando.yml` service:

The service needs a long-running command, because the image default command exits immediately after printing the version.

```yaml
services:
  appserver:
    type: php:8.4

  drupal-cs:
    type: compose
    services:
      image: timtom6891/drupal-cs:latest
      working_dir: /app
      volumes:
        - .:/app
      command: ["sh", "-lc", "while sleep 1000; do :; done"]

tooling:
  drupal-cs:
    service: drupal-cs
  phpcs:
    service: drupal-cs
    cmd: phpcs --standard=Drupal,DrupalPractice web/modules/custom
  phpcbf:
    service: drupal-cs
    cmd: phpcbf --standard=Drupal web/modules/custom
  drupal-check:
    service: drupal-cs
    cmd: drupal-check web/modules/custom
  phpstan:
    service: drupal-cs
    cmd: phpstan analyse web/modules/custom
  rector:
    service: drupal-cs
    cmd: rector process web/modules/custom
  twigcs:
    service: drupal-cs
    cmd: twigcs
  twigcbf:
    service: drupal-cs
    cmd: twigcbf
  composer-normalize:
    service: drupal-cs
    cmd: composer-normalize
  drupal-cs-init:
    service: drupal-cs
    cmd: drupal-cs-init
```

Commands:

```bash
lando drupal-cs
lando drupal-cs-init
lando drupal-cs-init --target-dir=web/modules/custom/example_module
lando phpcs
lando phpcbf
lando drupal-check
lando phpstan
lando rector
lando twigcs
lando twigcbf
lando composer-normalize
```

### DDEV

Example `.ddev/docker-compose.drupal-cs.yaml`:

This service also needs a long-running command, otherwise the container exits right away because the image default command is one-shot.

```yaml
services:
  drupal-cs:
    container_name: ddev-${DDEV_SITENAME}-drupal-cs
    image: timtom6891/drupal-cs:latest
    working_dir: /var/www/html
    volumes:
      - .:/var/www/html
    command: ["sh", "-lc", "while sleep 1000; do :; done"]
    labels:
      com.ddev.site-name: ${DDEV_SITENAME}
      com.ddev.approot: ${DDEV_APPROOT}
```

Commands:

```bash
ddev exec -s drupal-cs phpcs --version
ddev exec -s drupal-cs drupal-cs-init
ddev exec -s drupal-cs drupal-cs-init --target-dir=web/modules/custom/example_module
ddev exec -s drupal-cs phpcs --standard=Drupal,DrupalPractice web/modules/custom
ddev exec -s drupal-cs phpcbf --standard=Drupal web/modules/custom
ddev exec -s drupal-cs drupal-check web/modules/custom
ddev exec -s drupal-cs phpstan analyse web/modules/custom
ddev exec -s drupal-cs rector process web/modules/custom
ddev exec -s drupal-cs twigcs
ddev exec -s drupal-cs twigcbf
ddev exec -s drupal-cs composer-normalize
```

If you prefer named commands, add them to `.ddev/commands/web/`.

### Docksal

Example `.docksal/docksal.yml`:

As with Lando and DDEV, keep the container alive with a long-running command instead of the image default `CMD`.

```yaml
services:
  drupal-cs:
    image: timtom6891/drupal-cs:latest
    volumes:
      - ${PROJECT_ROOT}:/var/www
    working_dir: /var/www
    command: ["sh", "-lc", "while sleep 1000; do :; done"]
```

Commands:

```bash
fin exec -T drupal-cs drupal-cs-init
fin exec -T drupal-cs drupal-cs-init --target-dir=web/modules/custom/example_module
fin exec -T drupal-cs phpcs --standard=Drupal,DrupalPractice web/modules/custom
fin exec -T drupal-cs phpcbf --standard=Drupal web/modules/custom
fin exec -T drupal-cs drupal-check web/modules/custom
fin exec -T drupal-cs phpstan analyse web/modules/custom
fin exec -T drupal-cs rector process web/modules/custom
fin exec -T drupal-cs twigcs
fin exec -T drupal-cs twigcbf
fin exec -T drupal-cs composer-normalize
```

## Author

Taras Motuschuk
