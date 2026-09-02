#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

found=""

for member in "$ROOT"/*/; do
    [ -d "$member/.git" ] || continue

    for name in forge-register.yaml forge-ci.yaml forge-factory.yaml \
        .forge/session-config.yaml; do
        f="$member$name"

        [ -f "$f" ] || continue

        hit=$(grep -n -E '(127\.0\.0\.1|localhost|0\.0\.0\.0)' "$f" 2>/dev/null || true)

        [ -n "$hit" ] && found="$found
${f#"$ROOT"/}:
$hit"
    done
done

if [ -n "$found" ]; then
    echo "a committed config chooses a local stand-in as its data source:$found" >&2
    echo "" >&2
    echo "A stub belongs in a test, started in-process, where it is obviously a" >&2
    echo "double. In a config file it reads as a setting, and the answers it" >&2
    echo "gives get committed as facts." >&2
    exit 1
fi

echo "no data source points at a local stand-in"
