#!/bin/sh
# check-vendor.sh — the files vendored into mods/claude-accounts must stay byte-identical to
# herdr-shared/bin, exec bits included. Re-run herdr-shared/tools/vendor.sh after editing there.
set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
SHARED=${HERDR_SHARED:-$HOME/git-repo/herdr-shared}
FILES="cca usage-tap.sh usage-api.mjs codex-usage.mjs models.mjs"

if [ ! -d "$SHARED/bin" ]; then
  printf 'check-vendor: %s not found, skipping the vendored-copy check\n' "$SHARED"
  exit 0
fi

status=0
count=0
for name in $FILES; do
  src=$SHARED/bin/$name
  dst=$REPO/mods/claude-accounts/$name
  count=$((count + 1))
  if [ ! -f "$src" ]; then
    printf 'check-vendor: missing source %s\n' "$src" >&2
    status=1
    continue
  fi
  if [ ! -f "$dst" ]; then
    printf 'check-vendor: missing vendored %s\n' "$dst" >&2
    status=1
    continue
  fi
  if ! cmp -s "$src" "$dst"; then
    printf 'check-vendor: %s differs from %s; re-run vendor.sh\n' "$dst" "$src" >&2
    status=1
    continue
  fi
  src_exec=0
  dst_exec=0
  [ -x "$src" ] && src_exec=1
  [ -x "$dst" ] && dst_exec=1
  if [ "$src_exec" -ne "$dst_exec" ]; then
    printf 'check-vendor: %s exec bit differs from %s\n' "$dst" "$src" >&2
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  printf 'check-vendor: %s files match %s/bin\n' "$count" "$SHARED"
fi
exit $status
