#!/usr/bin/env bash
# Checks a builder image the way `larakube new` uses it: the tools are there, and a real project
# can be scaffolded with them.
#   scripts/smoke.sh <image> <package>
set -euo pipefail

image="${1:?image}"
package="${2:?package}"
work="$(mktemp -d)"

# The scaffold runs as root in the container, so on Linux the files it makes belong to root and the
# runner's own user cannot delete them. Empty the folder from inside a container first.
cleanup() {
  docker run --rm -v "$work:/w" --user root --entrypoint sh "$image" -c 'rm -rf /w/* /w/.[!.]* 2>/dev/null; true' >/dev/null 2>&1 || true
  rm -rf "$work" 2>/dev/null || true
}
trap cleanup EXIT

case "$package" in
  php)
    docker run --rm "$image" sh -c 'php -v | head -n1 && composer --version && node -v && npm -v && bun --version && laravel --version && statamic --version'
    docker run --rm -v "$work:/var/www/html" -e COMPOSER_CACHE_DIR=/dev/null -e COMPOSER_ALLOW_SUPERUSER=1 \
      -e SHOW_WELCOME_MESSAGE=false --user root "$image" \
      sh -c 'laravel new smoke-app --no-interaction --database=sqlite --no-boost >/dev/null'
    test -f "$work/smoke-app/artisan" || { echo "laravel new did not create an app" >&2; exit 1; }
    ;;
  python)
    docker run --rm "$image" sh -c 'python --version && django-admin --version'
    docker run --rm -v "$work:/app" -w /app --user root "$image" sh -c 'django-admin startproject config .'
    test -f "$work/manage.py" || { echo "django-admin did not create a project" >&2; exit 1; }
    ;;
  *)
    echo "unknown package $package" >&2
    exit 1
    ;;
esac

echo "ok: $image"
