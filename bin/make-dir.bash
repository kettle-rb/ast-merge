#!/usr/bin/env bash

# Creates a directory path inside each destination directory matched by provided glob(s)
# Usage: bin/make-dir.bash <dir-to-create> <dest-glob> [<dest-glob>...]
# Example: bin/make-dir.bash path/to/newdir vendor/*-merge/

set -euo pipefail
shopt -s nullglob

usage() {
  cat <<USAGE >&2
Usage: $(basename "$0") <dir-to-create> <dest-glob> [<dest-glob>...]

Creates <dir-to-create> within each directory matched by <dest-glob>.
If the <dir-to-create> starts with a '/', the leading slash will be trimmed and
the directory will be created inside the destination directory.

Examples:
  $(basename "$0") foo vendor/*-merge/
  $(basename "$0") path/to/subdir "vendor/*-merge/"
USAGE
}

if [ "${#}" -lt 2 ]; then
  echo "Error: expected at least 2 arguments (path-to-create and one or more dest patterns)." >&2
  usage
  exit 1
fi

DIR_TO_CREATE="$1"
shift
DEST_PATTERNS=("$@")

# Normalize: remove leading slash so we always create inside the destination
if [[ "$DIR_TO_CREATE" == /* ]]; then
  DIR_TO_CREATE="${DIR_TO_CREATE#/}"
fi

count=0

for pattern in "${DEST_PATTERNS[@]}"; do
  matches=()
  # Expand the pattern (this allows quoted globs to expand here)
  for dest in $pattern; do
    matches+=("$dest")
  done

  # If no matches from glob expansion, but the pattern itself exists as a path, use it
  if [ ${#matches[@]} -eq 0 ]; then
    if [ -e "$pattern" ]; then
      matches+=("$pattern")
    fi
  fi

  for dest in "${matches[@]}"; do
    if [ -d "$dest" ]; then
      fullpath="$dest/$DIR_TO_CREATE"
      if mkdir -p "$fullpath"; then
        echo "Created: $fullpath"
        count=$((count + 1))
      else
        echo "Failed to create: $fullpath" >&2
      fi
    else
      echo "Skipping: '$dest' is not an existing directory" >&2
    fi
  done
done

if [ "$count" -eq 0 ]; then
  echo "No directories were created. Check patterns or destination directories exist." >&2
  exit 2
fi

echo "Success: created '$DIR_TO_CREATE' in $count destination(s)."
exit 0
