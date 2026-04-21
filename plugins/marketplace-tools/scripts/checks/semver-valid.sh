#!/usr/bin/env bash
# Valida se version casa com SemVer (https://semver.org).
# Uso: semver-valid.sh <version_string> <plugin_name>
# Exit: 0 ok, 1 inválido, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em semver-valid.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

VERSION="${1:-}"
PLUGIN_NAME="${2:-}"

if [ -z "$VERSION" ] || [ -z "$PLUGIN_NAME" ]; then
  echo "Uso: semver-valid.sh <version_string> <plugin_name>" >&2
  exit 2
fi

SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$'

if [[ "$VERSION" =~ $SEMVER_RE ]]; then
  exit 0
fi

echo "LOW|semver-invalid|$PLUGIN_NAME|semver-invalid: '$VERSION' não casa com SemVer (formato esperado: MAJOR.MINOR.PATCH[-pre][+build])|no"
exit 1
