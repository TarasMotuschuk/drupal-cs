# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning where possible.

## [Unreleased]

### Added
- `drupal-low`, `drupal-base`, `drupal-strict`, `drupal7`, `drupal8`, `drupal9`, and `drupal10` PHPCS presets for `drupal-cs-init`, while keeping `drudev` as a backward-compatible alias.
- GitHub Actions workflow for multi-arch Docker build verification on pull requests and Docker Hub publish on `main`, tags, and manual runs.

### Changed
- Pinned `drudev/drudev-ccs` to `1.0.3` so local builds and the Docker publish pipeline install the PHPCS presets added in that release (`DrupalStrict`, `DrupalBase`, `DrupalLow`, `Drupal7`, `Drupal8`, `Drupal9`, `Drupal10`).
- Registered `PHPCompatibility` and `WPCS` PHPCS standards in the image so the new version-aware presets work out of the box.
- Declared the Docker base stage with `TARGETPLATFORM` so the image build remains compatible with both `linux/amd64` and `linux/arm64`.
- Reworked the `README.md` and `DOCKER_HUB_DESCRIPTION.md` intros with clearer headings, Docker Hub and GitHub links, keyword-oriented copy, and badges in the repository README.
- Removed the Composer auth secret requirement from the Docker build flow and updated the build docs accordingly.

## [0.2.0] - 2026-03-24

### Added
- `CHANGELOG.md` for tracking project changes.
- `AGENTS.md` with agent-oriented project guidance and runbook commands.
- Dedicated `drupal-cs-init` sections in `README.md` and Docker Hub description with detailed behavior, options, presets, pipeline generation, and examples.
- `Author` section in `README.md` and Docker Hub description.
- `LICENSE` file with the MIT license text.
- OCI image labels in `Dockerfile` for Docker Hub and container metadata consumers.
- Richer package metadata in `composer.json` (`keywords`, `homepage`, `authors`).
- A command overview section and stronger keyword-oriented project summary in `README.md`.
- `drudev/drudev-ccs` bundled into the image as the primary PHPCS standards source.

### Changed
- Switched the bundled Drupal standards setup to the `drudev/drudev-ccs` package.
- Updated the bundled `drupal-check` implementation to `drudev/drupal-check`.
- Updated the bundled static-analysis stack to `phpstan` 2.x.
- Renamed the `drupal-cs-init` documentation section to explicitly cover both config and CI pipeline generation.
- Moved the `Author` section to the end of `README.md` and Docker Hub description so it no longer interrupts integration examples.
- Updated the documented author name to `Taras Motuschuk`.
- Shortened `DOCKER_HUB_DESCRIPTION.md` while keeping the opening summary and `Commands At A Glance` section aligned with `README.md`.
- Restored the detailed `drupal-cs-init` section and the `Lando`, `DDEV`, and `Docksal` integration examples in `DOCKER_HUB_DESCRIPTION.md`.
- Removed `drudev` preset mentions from `DOCKER_HUB_DESCRIPTION.md`.

## [0.1.0] - 2026-03-24

### Added
- Initial Docker image setup on `php:8.4-cli-alpine`.
- Preinstalled Drupal QA and refactoring tools via Composer:
  - `phpcs` / `phpcbf` with Drupal standards
  - `phpstan`
  - `drupal-check`
  - `rector` (`palantirnet/drupal-rector`)
  - `twig-cs-fixer`
  - `composer-normalize`
- Wrapper scripts in `bin/`:
  - `drupal-cs-init` for generating baseline config files (`phpcs.xml`, `.twig-cs-fixer.php`, `phpstan.neon.dist`, `rector.php`)
  - `twigcs`, `twigcbf`
  - `composer-normalize`
- `docker-compose.yml` and `Makefile` convenience commands.
- Build flow with Composer auth secret support (`auth.json` / `auth.example.json`).
