#!/bin/sh
set -eu

ROOT="${1:-..}"

fix() {
    echo "  from nothing:   forge clone <this factory's url> $ROOT" >&2
    echo "  after editing:  pass --config workspace/$1 to forge-factory" >&2
}

sh "$(dirname "$0")/tracked-and-ignored.sh" "$ROOT"

for f in forge-factory.yaml forge-ci.yaml; do
    if [ ! -f "$ROOT/$f" ]; then
        echo "no $f at $ROOT." >&2
        fix "$f"
        exit 1
    fi

    if ! cmp -s "workspace/$f" "$ROOT/$f"; then
        echo "$f here and the one in play disagree." >&2
        fix "$f"
        diff -u "workspace/$f" "$ROOT/$f" >&2 || true
        exit 1
    fi
done

if ! command -v forge-factory >/dev/null 2>&1; then
    echo "the factory matches the one in play. forge-factory is not installed, so"
    echo "it was not validated."
    exit 0
fi

forge-factory validate --config "$ROOT/forge-factory.yaml" >/dev/null

echo "the factory matches the one in play and forge-factory reads it"
