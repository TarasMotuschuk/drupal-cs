# AGENTS

## Purpose
This repository builds a Docker image with Drupal code quality tooling on PHP 8.4.

Primary tools inside the container:
- `phpcs`, `phpcbf`
- `phpstan`
- `drupal-check`
- `rector`
- `twig-cs-fixer` (via `twigcs` / `twigcbf` wrappers)
- `composer-normalize`

## Repository map
- `Dockerfile` - image build, Composer install, global symlinks for tooling binaries.
- `composer.json` - tool dependencies and Composer scripts.
- `bin/drupal-cs-init` - generates baseline config files for Drupal projects.
- `bin/twigcs`, `bin/twigcbf`, `bin/composer-normalize` - helper wrappers.
- `docker-compose.yml` - local service definition.
- `Makefile` - shortcuts for common container commands.
- `README.md` - usage examples for Docker, Docker Compose, and Lando.

## Quick commands
Build image (requires Composer auth file):
```bash
make build
```

Show installed phpcs version:
```bash
docker compose run --rm drupal-cs
```

Generate baseline configs in the mounted project:
```bash
docker compose run --rm drupal-cs drupal-cs-init
```

Run analyzers:
```bash
docker compose run --rm drupal-cs phpcs --standard=Drupal,DrupalPractice web/modules/custom
docker compose run --rm drupal-cs drupal-check web/modules/custom
docker compose run --rm drupal-cs phpstan analyse web/modules/custom
docker compose run --rm drupal-cs rector process web/modules/custom
docker compose run --rm drupal-cs composer-normalize
```

## Notes for agents
- Wrapper scripts must resolve project files in this order: explicit target/argument, current working directory, then `/app`.
- Build depends on Composer auth secret (`composer_auth`) for private packages.
- Do not remove existing wrapper scripts in `bin/`; they are part of public CLI behavior.
- Keep docs and command examples aligned with the actual image tag (`php8.4`) and tooling list.
- Document every user-visible change in `CHANGELOG.md`: add entries under `## [Unreleased]` during development and move them to a versioned section on release.
