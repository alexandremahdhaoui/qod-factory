#!/bin/sh
set -eu

ROOT="${1:-..}"

bad=0

for repo in "$ROOT"/*/; do
    [ -d "$repo/.git" ] || continue

    listed=$(git -C "$repo" ls-files --cached --ignored --exclude-standard)
    [ -z "$listed" ] && continue

    bad=1
    name=$(basename "$repo")
    echo "$name tracks files its .gitignore also ignores:" >&2
    echo "$listed" | sed "s/^/  $name\//" >&2
done

if [ "$bad" -ne 0 ]; then
    echo "a tracked file is never ignored: every regeneration dirties the tree," >&2
    echo "the revision goes -dirty, and the release refuses forever." >&2
    echo "untrack the file or drop the .gitignore line." >&2
    exit 1
fi

echo "no repo tracks a file it also ignores"
