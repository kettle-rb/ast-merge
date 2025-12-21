#!/bin/sh
set -e  # Exit on error

# Install basic development dependencies for Ruby & JRuby projects
apt-get update -y
apt-get install -y direnv default-jdk git zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev

# Support for PostgreSQL (commented out by default)
# apt-get install -y postgresql libpq-dev

# Run the shared tree-sitter setup script (without sudo since we're already root in devcontainer)
# This gem needs ALL grammars for integration testing
# The script location depends on where the workspace is mounted
# Try common locations in order
SETUP_SCRIPT=""
for candidate in \
  "/IdeaProjects/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" \
  "/workspaces/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" \
  "/workspace/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" \
  "/home/vscode/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" \
  "/root/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh"; do
  if [ -f "$candidate" ]; then
    SETUP_SCRIPT="$candidate"
    break
  fi
done

if [ -z "$SETUP_SCRIPT" ]; then
  echo "ERROR: Cannot find setup-tree-sitter.sh in any expected location" >&2
  echo "Tried:" >&2
  echo "  /IdeaProjects/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" >&2
  echo "  /workspaces/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" >&2
  echo "  /workspace/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" >&2
  echo "  /home/vscode/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" >&2
  echo "  /root/ast-merge/.github/scripts/ubuntu/setup-tree-sitter.sh" >&2
  exit 1
fi

echo "Running tree-sitter setup script from: $SETUP_SCRIPT"
# Extract workspace root from script path
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$SETUP_SCRIPT")")")")"
echo "Workspace root: $WORKSPACE_ROOT"

# Pass the actual workspace path to the setup script
bash "$SETUP_SCRIPT" --workspace="$WORKSPACE_ROOT" 2>&1 | tee /tmp/tree-sitter-setup.log

# Check if all grammars were installed
echo "Checking for multi-grammar installation..."
for grammar in toml json jsonc bash; do
  if [ ! -f "/usr/local/lib/libtree-sitter-${grammar}.so" ]; then
    echo "WARNING: tree-sitter-${grammar}.so was not installed" >&2
  fi
done

echo "tree-sitter setup completed"

# Adds the direnv setup script to ~/.bashrc file (at the end)
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
