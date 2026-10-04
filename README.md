# LaraKube builder images

Images that the LaraKube CLI's `new` commands run in, with the tools a scaffold needs already
installed, so a new project does not install them on every run.

| Image | Used by | Preinstalled |
| --- | --- | --- |
| `ghcr.io/luchavez-technologies/larakube-builder/php:<8.3\|8.4\|8.5>` | `larakube new` (Laravel), `larakube statamic:new` | Server Side Up `cli-alpine`, Node, npm, Bun, `laravel/installer`, `statamic/cli` |
| `ghcr.io/luchavez-technologies/larakube-builder/python:3.12` | `larakube django:new` | Python 3.12 (slim) with Django |

Tags: `<version>` always points at the newest build; `<version>-r<YYYYMMDD>` is fixed. The CLI falls
back to the plain base image, set up on each run, when a builder cannot be pulled.

## How it works
- `images.json` lists the images: the package, its version, the base image, the Dockerfile, and the
  Composer or pip packages to preinstall.
- **When it rebuilds.** Daily, a job compares each base image's digest, and a hash of the Dockerfile and
  the preinstalled tools' latest versions, with the labels on the published image. A change in any of them
  rebuilds just that image. Run the workflow with *force* to rebuild everything.
- **What is checked.** Each image is built, then used to scaffold a real project (a Laravel app, a Django
  project) before it is pushed.
- **Both architectures.** amd64 and arm64 are built on native runners and joined into one tag.
- **Staying in step with the CLI.** A non-blocking job reports when the CLI pulls a builder that is not
  listed here.

## Add an image
Add an entry to `images.json` (and a Dockerfile if it is a new kind), and teach `scripts/smoke.sh` how to
scaffold with it. The LaraKube CLI must also be taught to use it.

## Try one locally
```bash
docker build -f php/Dockerfile -t builder-php \
  --build-arg BASE_IMAGE=docker.io/serversideup/php:8.4-cli-alpine \
  --build-arg COMPOSER_GLOBAL="laravel/installer statamic/cli:^3.6" .
scripts/smoke.sh builder-php php
```

## Setup (once)
After the first successful run, open each package on GitHub (Packages) and set its visibility to **public**,
so a computer can pull it without credentials.
