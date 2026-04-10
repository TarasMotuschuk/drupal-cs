# Drupal CS Docker Image for PHP 8.4

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-timtom6891%2Fdrupal--cs-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/repository/docker/timtom6891/drupal-cs/general)
[![GitHub](https://img.shields.io/badge/GitHub-TarasMotuschuk%2Fdrupal--cs-181717?logo=github&logoColor=white)](https://github.com/TarasMotuschuk/drupal-cs)
[![Docker Publish](https://github.com/TarasMotuschuk/drupal-cs/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/TarasMotuschuk/drupal-cs/actions/workflows/docker-publish.yml)
[![PHP 8.4](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)](https://www.php.net/releases/8.4/en.php)
[![Platforms](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-0db7ed)](https://hub.docker.com/repository/docker/timtom6891/drupal-cs/general)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

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

## Build And Publish

Build a local image:

```bash
docker build -t drupal-cs:latest .
```

Or use `make`:

```bash
make build
```

For CI systems that run on Linux/X86_64, such as Bitbucket hosted runners, you need an `amd64`-compatible image. If you build and push from Apple Silicon, publish either an explicit `linux/amd64` image or a multi-arch manifest:

```bash
make build-amd64 IMAGE=drupal-cs:latest
make build-multiarch-push PUBLISH_IMAGE=timtom6891/drupal-cs:latest
```

`build-amd64` creates a local `linux/amd64` image. `build-multiarch-push` publishes a manifest for `linux/amd64,linux/arm64`.

## GitHub Actions

The repository includes [`.github/workflows/docker-publish.yml`](/Users/taras/Projects/OWN-GITHUB/drupal-cs/.github/workflows/docker-publish.yml) for Docker CI/CD.

- `pull_request`: builds the multi-arch image without pushing
- `push` to `main`: builds and pushes `latest` plus a commit-SHA tag
- `push` tag `v*`: builds and pushes version tags
- `workflow_dispatch`: allows manual runs from GitHub Actions

Configure these repository secrets before enabling pushes:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## Pull

```bash
docker pull timtom6891/drupal-cs:latest
```

## Usage

The image is intended for running checks against a mounted Drupal project.

Check the installed version:

```bash
docker run --rm drupal-cs:latest
```

Run `phpcs` for the current project:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest \
  phpcs --standard=Drupal,DrupalPractice web/modules/custom
```

Automatically fix what `phpcbf` can fix:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest \
  phpcbf --standard=Drupal web/modules/custom
```

Run `drupal-check` against a Drupal project:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest \
  drupal-check web/modules/custom
```

Run `phpstan`:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest \
  phpstan analyse web/modules/custom
```

Normalize `composer.json`:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest \
  composer-normalize
```

Run the Twig CS wrappers:

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest twigcs
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest twigcbf
```

## Config And Pipeline Generation (`drupal-cs-init`)

The image includes a built-in `drupal-cs-init` command that bootstraps baseline static-analysis configs and optional CI pipeline templates for a Drupal project.

### Generated config files

- `phpcs.xml`
- `.twig-cs-fixer.php`
- `phpstan.neon.dist`
- `rector.php`

Default behavior:

- writes files to the current working directory
- skips files that already exist
- creates `tmp/` in the target directory

Use `--force` to overwrite existing files.

### Presets

- `basic` (default): generic Drupal-oriented starter configs
- `drudev`: backward-compatible alias of the strict Drudev/Drupal preset
- `drupal-low`: light Drupal PHPCS baseline based on `DrupalLow`
- `drupal-base`: Drupal PHPCS baseline with `DrupalPractice`
- `drupal-strict`: strict Drupal PHPCS baseline based on `DrupalStrict`
- `drupal7`: Drupal 7 PHPCS baseline with PHP compatibility checks for legacy runtimes
- `drupal8`: Drupal 8 PHPCS baseline with PHP compatibility checks
- `drupal9`: Drupal 9 PHPCS baseline with PHP compatibility checks
- `drupal10`: Drupal 10 PHPCS baseline with PHP compatibility checks

All Drupal-specific presets keep the stricter Twig, PHPStan, and Rector starter configs; the preset mainly selects the generated `phpcs.xml` ruleset.

### Command options

- `--preset=basic|drudev|drupal-low|drupal-base|drupal-strict|drupal7|drupal8|drupal9|drupal10`
- `--ci=all|bitbucket,github,gitlab`
- `--target-dir=PATH`
- positional target dir (`drupal-cs-init some/path`)
- `--force`
- `--help`

### Pipeline generation

- `--ci=bitbucket` generates `bitbucket-pipelines.yml`
- `--ci=github` generates `.github/workflows/drupal-cs.yml`
- `--ci=gitlab` generates `.gitlab-ci.yml`
- `--ci=all` generates all three templates

Generated pipelines use `timtom6891/drupal-cs:latest` and run `composer-normalize --dry-run`, `phpcs`, `drupal-check`, `twigcs`, `phpstan`, and `rector --dry-run`.

### Examples

```bash
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --preset=drudev
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --preset=drupal-base
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --preset=drupal10
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --ci=all
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --ci=github,gitlab
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --target-dir=web/modules/custom/example_module
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init web/modules/custom/example_module
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --force
docker run --rm -v "$PWD":/app -w /app drupal-cs:latest drupal-cs-init --help
```

## CI examples

### Bitbucket

Generated file: `bitbucket-pipelines.yml`

```yaml
image: timtom6891/drupal-cs:latest

definitions:
  steps:
    - step: &composer-normalize
        name: Composer Normalize
        script:
          - composer-normalize --dry-run
    - step: &phpcs
        name: PHPCS
        script:
          - phpcs --standard=phpcs.xml web/modules/custom web/themes/custom
    - step: &drupal-check
        name: Drupal Check
        script:
          - drupal-check web/modules/custom
    - step: &twigcs
        name: Twig CS
        script:
          - twigcs
    - step: &phpstan
        name: PHPStan
        script:
          - phpstan analyse
    - step: &rector
        name: Rector
        script:
          - rector process --dry-run

pipelines:
  default:
    - parallel:
        fail-fast: true
        steps:
          - step: *composer-normalize
          - step: *phpcs
          - step: *drupal-check
          - step: *twigcs
          - step: *phpstan
          - step: *rector
```

### GitHub Actions

Generated file: `.github/workflows/drupal-cs.yml`

```yaml
name: Drupal CS

on:
  push:
  pull_request:

jobs:
  drupal-cs:
    runs-on: ubuntu-latest
    container:
      image: timtom6891/drupal-cs:latest
    steps:
      - uses: actions/checkout@v4
      - name: Composer Normalize
        run: composer-normalize --dry-run
      - name: PHPCS
        run: phpcs --standard=phpcs.xml web/modules/custom web/themes/custom
      - name: Drupal Check
        run: drupal-check web/modules/custom
      - name: Twig CS
        run: twigcs
      - name: PHPStan
        run: phpstan analyse
      - name: Rector
        run: rector process --dry-run
```

### GitLab CI

Generated file: `.gitlab-ci.yml`

```yaml
image: timtom6891/drupal-cs:latest

stages:
  - lint
  - static
  - modernize

composer_normalize:
  stage: lint
  script:
    - composer-normalize --dry-run

phpcs:
  stage: lint
  script:
    - phpcs --standard=phpcs.xml web/modules/custom web/themes/custom

drupal_check:
  stage: lint
  script:
    - drupal-check web/modules/custom

twigcs:
  stage: lint
  script:
    - twigcs

phpstan:
  stage: static
  script:
    - phpstan analyse

rector:
  stage: modernize
  script:
    - rector process --dry-run
```

## Integration examples

### Docker

Pull the published image:

```bash
docker pull timtom6891/drupal-cs:latest
```

All common commands with plain Docker:

```bash
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-cs-init
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpcs --standard=Drupal,DrupalPractice web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpcbf --standard=Drupal web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest drupal-check web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest phpstan analyse web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest rector process web/modules/custom
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest twigcs
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest twigcbf
docker run --rm -v "$PWD":/app -w /app timtom6891/drupal-cs:latest composer-normalize
```

### Docker Compose

Example service:

```yaml
services:
  drupal-cs:
    image: timtom6891/drupal-cs:latest
    working_dir: /app
    volumes:
      - .:/app
```

Commands:

```bash
docker compose run --rm drupal-cs
docker compose run --rm drupal-cs drupal-cs-init
docker compose run --rm drupal-cs phpcs --standard=Drupal,DrupalPractice web/modules/custom
docker compose run --rm drupal-cs phpcbf --standard=Drupal web/modules/custom
docker compose run --rm drupal-cs drupal-check web/modules/custom
docker compose run --rm drupal-cs phpstan analyse web/modules/custom
docker compose run --rm drupal-cs rector process web/modules/custom
docker compose run --rm drupal-cs twigcs
docker compose run --rm drupal-cs twigcbf
docker compose run --rm drupal-cs composer-normalize
```

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
fin exec -T drupal-cs phpcs --version
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

## Compose

The repository includes [docker-compose.yml](/Users/taras/Projects/OWN/drupal-cs/docker-compose.yml), so you can run commands more concisely:

```bash
docker compose run --rm drupal-cs drupal-cs-init
docker compose run --rm drupal-cs phpcs --standard=Drupal,DrupalPractice web/modules/custom
docker compose run --rm drupal-cs drupal-check web/modules/custom
docker compose run --rm drupal-cs twigcs
```

## Make

The repository also includes [Makefile](/Users/taras/Projects/OWN/drupal-cs/Makefile) with ready-to-use targets:

```bash
make build
make version
make init-configs
make phpcs
make phpcbf
make drupal-check
make phpstan
make rector
make twigcs
make twigcbf
make composer-normalize
make shell
```

`make build` creates a local image for the current host architecture.

## Notes

- Base image: `php:8.4-cli-alpine`
- Installed tools include `drupal/coder`, `drupal-check`, `drupal-rector`, `phpstan`, `composer-normalize`, `gskema/phpcs-type-sniff`, and `twig-cs-fixer`
- The image bundles `drudev/drudev-ccs` as the PHPCS standards source
- Wrapper commands `drupal-cs-init`, `twigcs`, `twigcbf`, and `composer-normalize` are available in `PATH`
- The image `composer.json` defines `scripts` for `twigcs` and `twigcbf`
- To avoid duplicate PHPCS class loading, do not point your project `phpcs.xml` to local `vendor/...` standards when using this image

## Author

Taras Motuschuk
