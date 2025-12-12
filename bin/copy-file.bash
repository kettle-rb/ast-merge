#!/usr/bin/env bash

# Copies a single source file into multiple destination directories (or destination file paths)
# Usage: bin/copy-file.bash <source-file> <dest-glob>
# Example: bin/copy-file.bash Appraisals vendor/*-merge/

set -euo pipefail
shopt -s nullglob

usage() {
  cat <<USAGE >&2
Usage: $(basename "$0") <source-file> <dest-glob>

Copies <source-file> into each destination directory matched by <dest-glob>.
If a matched entry is a directory, the file is copied with the same basename.
If a matched entry is a file path and its parent directory exists, the file is copied to that exact path.

Example:
  $(basename "$0") Appraisals vendor/*-merge/
USAGE
}

if [ "${#}" -lt 2 ]; then
  echo "Error: expected at least 2 arguments (source and one or more dest patterns/paths)." >&2
  usage
  exit 1
fi

SOURCE_FILE="$1"
shift
DEST_PATTERNS=("$@")

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: source file '$SOURCE_FILE' does not exist or is not a regular file." >&2
  exit 1
fi

NAME=$(basename "$SOURCE_FILE")
count=0

for pattern in "${DEST_PATTERNS[@]}"; do
  # Expand the pattern into matching paths. If the pattern is quoted on the command
  # line, it will still be expanded here (because the variable is unquoted in the
  # loop below); if it was already expanded by the shell, it will be a literal path
  # and will be processed directly.
  matches=()
  for dest in $pattern; do
    matches+=("$dest")
  done

  # If no matches from glob expansion, check if the pattern itself exists as a path
  if [ ${#matches[@]} -eq 0 ]; then
    if [ -e "$pattern" ]; then
      matches+=("$pattern")
    fi
  fi

  for dest in "${matches[@]}"; do
  # If dest is a directory, copy the file as <directory>/<basename>
  if [ -d "$dest" ]; then
    dest_path="$dest/$NAME"
  else
    # If it's not a directory, but the destination's parent dir exists, use the exact path
    parent_dir=$(dirname "$dest")
    if [ -d "$parent_dir" ]; then
      dest_path="$dest"
    else
      # Not a directory and parent missing, skip
      continue
    fi
  fi

  if cp -f "$SOURCE_FILE" "$dest_path"; then
    echo "Copied: '$SOURCE_FILE' -> '$dest_path'"
    count=$((count + 1))
  else
    echo "Failed to copy to '$dest_path'" >&2
  fi
  done
done

if [ "$count" -eq 0 ]; then
  echo "No destinations matched pattern '$DEST_GLOB' or suitable directories were not found." >&2
  exit 2
fi

echo "Success: copied '$SOURCE_FILE' to $count destination(s)."
exit 0
