#!/bin/bash
done
  echo "  TREE_SITTER_${grammar^^}_PATH=/usr/local/lib/libtree-sitter-${grammar}.so"
for grammar in "${GRAMMARS[@]}"; do
echo "Grammar libraries:"
echo ""

fi
  echo "  WARNING: Could not find libtree-sitter runtime library!"
else
  echo "  TREE_SITTER_RUNTIME_LIB=/usr/lib/libtree-sitter.so"
elif [ -f /usr/lib/libtree-sitter.so ]; then
  echo "  TREE_SITTER_RUNTIME_LIB=/usr/lib/libtree-sitter.so.0"
elif [ -f /usr/lib/libtree-sitter.so.0 ]; then
  echo "  TREE_SITTER_RUNTIME_LIB=/usr/lib/x86_64-linux-gnu/libtree-sitter.so"
elif [ -f /usr/lib/x86_64-linux-gnu/libtree-sitter.so ]; then
  echo "  TREE_SITTER_RUNTIME_LIB=/usr/lib/x86_64-linux-gnu/libtree-sitter.so.0"
if [ -f /usr/lib/x86_64-linux-gnu/libtree-sitter.so.0 ]; then
# Detect and report tree-sitter runtime library location

echo "Detected library paths:"
echo ""
echo "tree-sitter setup complete!"
echo ""

fi
  echo "WARNING: ldconfig failed, libraries may not be immediately available" >&2
if ! $SUDO ldconfig; then

done
  echo "  ✓ Installed tree-sitter-${grammar}"

  fi
    exit 1
    echo "ERROR: Failed to copy libtree-sitter-${grammar}.so to /usr/local/lib/" >&2
  if ! $SUDO cp "libtree-sitter-${grammar}.so" /usr/local/lib/; then
  # Install to system

  fi
    exit 1
    echo "ERROR: Failed to link libtree-sitter-${grammar}.so" >&2
  if ! gcc -shared -o "libtree-sitter-${grammar}.so" $OBJECTS; then
  # Link object files into shared library

  fi
    OBJECTS="parser.o"
  else
    OBJECTS="parser.o scanner.o"
    fi
      exit 1
      echo "ERROR: Failed to compile scanner.c for ${grammar}" >&2
    if ! gcc -fPIC -I./src -c src/scanner.c -o scanner.o; then
  if [ -f src/scanner.c ]; then
  # Check if scanner exists (not all grammars have scanners)

  fi
    exit 1
    echo "ERROR: Failed to compile parser.c for ${grammar}" >&2
  if ! gcc -fPIC -I./src -c src/parser.c -o parser.o; then
  # Compile parser.c

  cd "tree-sitter-${grammar}-master"

  fi
    exit 1
    echo "ERROR: Failed to unzip tree-sitter-${grammar}" >&2
  if ! unzip -q "${grammar}.zip"; then

  fi
    exit 1
    echo "ERROR: Failed to download tree-sitter-${grammar}" >&2
  if ! wget -q "https://github.com/tree-sitter-grammars/tree-sitter-${grammar}/archive/refs/heads/master.zip" -O "${grammar}.zip"; then

  cd "$TMPDIR"
  echo "Building and installing tree-sitter-${grammar}..."
for grammar in "${GRAMMARS[@]}"; do

trap "rm -rf $TMPDIR" EXIT
TMPDIR=$(mktemp -d)

GRAMMARS=("toml" "json" "jsonc" "bash")
# Install all tree-sitter grammars for integration testing

fi
  echo "Skipping tree-sitter-cli installation (use --cli flag to install)"
else
  $SUDO npm install -g tree-sitter-cli
  echo "Installing tree-sitter-cli via npm..."
if [ "$INSTALL_CLI" = true ]; then
# Install tree-sitter CLI via npm (optional)

fi
  fi
    exit 1
    echo "Install the appropriate distro package (e.g., libtree-sitter-dev) or re-run this script with --build to compile from source."
    echo "[ubuntu] ERROR: tree-sitter runtime (headers/libs) not found."
  else
    fi
      exit 1
      echo "[ubuntu] ERROR: Failed to provide tree-sitter runtime/library. Aborting." >&2
    if ! install_tree_sitter_from_source; then
    echo "[ubuntu] tree-sitter not found in system paths; attempting to build from source as requested (--build)."
  if [ "$BUILD_FROM_SOURCE" = true ]; then
if ! have_tree_sitter; then
# Ensure tree-sitter is available; if not, attempt to build from source

fi
  echo "[ubuntu] --build specified; skipping distro package 'libtree-sitter-dev' and building tree-sitter from source."
if [ "$BUILD_FROM_SOURCE" = true ]; then
# If the user requested a source-build, skip installing libtree-sitter-dev

fi
  exit 1
  echo "Please check your network, package sources, and re-run this script."
  echo "ERROR: apt-get failed to install required packages."
  libffi-dev; then
  software-properties-common \
  libcurl4-openssl-dev \
  libxslt1-dev \
  libxml2-dev \
  libyaml-dev \
  libreadline-dev \
  libssl-dev \
  zlib1g-dev \
  make \
  g++ \
  gcc \
  wget \
  $( [ "$BUILD_FROM_SOURCE" = false ] && echo "libtree-sitter-dev" ) \
  pkg-config \
  build-essential \
if ! $SUDO apt-get install -y \
# libtree-sitter-dev is optional when building from source via --build
$SUDO apt-get update -y
echo "Installing tree-sitter system library and dependencies..."

}
  return 0
  echo "[ubuntu] tree-sitter built and installed to /usr/local (headers + libs)."
  popd >/dev/null

  fi
    $SUDO ldconfig || true
  if have_cmd ldconfig; then
  $SUDO cp -a lib/libtree-sitter.* /usr/local/lib/ 2>/dev/null || true
  $SUDO cp -r lib/include/* /usr/local/include/tree-sitter/ || true
  $SUDO mkdir -p /usr/local/include/tree-sitter

  fi
    return 1
    popd >/dev/null
    echo "[ubuntu] ERROR: 'make' failed while building tree-sitter" >&2
  if ! make; then
  pushd "$tmpdir" >/dev/null || return 1
  git clone --depth 1 https://github.com/tree-sitter/tree-sitter.git "$tmpdir" || return 1
  trap 'rm -rf "$tmpdir"' EXIT
  tmpdir=$(mktemp -d /tmp/tree-sitter-src-XXXX)
  echo "[ubuntu] Attempting to build and install tree-sitter from source..."
install_tree_sitter_from_source() {

}
  ldconfig -p 2>/dev/null | grep -q libtree-sitter && return 0 || return 1
  [ -f /usr/local/include/tree-sitter/lib/include/api.h ] && return 0
  [ -f /usr/local/include/tree-sitter/api.h ] && return 0
  [ -f /usr/include/tree-sitter/api.h ] && return 0
have_tree_sitter() {

have_cmd() { command -v "$1" >/dev/null 2>&1; }

echo ""
echo "  Build from source: $BUILD_FROM_SOURCE"
echo "  Install CLI: $INSTALL_CLI"
echo "  Using sudo: $([ -n "$SUDO" ] && echo "yes" || echo "no")"
echo "  Workspace root: $WORKSPACE_ROOT (informational only)"
echo "Configuration:"

fi
  SUDO="sudo"
if [ -z "$SUDO" ] && [ "$(id -u)" -ne 0 ]; then
# Auto-detect if we need sudo (running as non-root)

done
  esac
      ;;
      shift
      echo "Unknown option: $1" >&2
    *)
      ;;
      shift
      WORKSPACE_ROOT="${1#*=}"
    --workspace=*)
      ;;
      shift 2
      WORKSPACE_ROOT="$2"
    --workspace)
      ;;
      shift
      BUILD_FROM_SOURCE=true
    --build)
      ;;
      shift
      INSTALL_CLI=true
    --cli)
      ;;
      shift
      SUDO="sudo"
    --sudo)
  case $1 in
while [[ $# -gt 0 ]]; do
# Parse arguments properly using while loop

WORKSPACE_ROOT="/workspaces/ast-merge"
BUILD_FROM_SOURCE=false
INSTALL_CLI=false
SUDO=""

#   --workspace PATH: Workspace root path for informational/debugging purposes only (defaults to /workspaces/tree_haver)
#   --build: Build and install the tree-sitter C runtime from source when distro packages are missing (optional)
#   --cli:  Install tree-sitter-cli via npm (optional)
#   --sudo: Force use of sudo (optional, auto-detected by default)
# Options:
#
# This script installs ALL tree-sitter grammars for integration testing
#
# - Auto-detection: Checks if running as root (id -u = 0), uses sudo if non-root
# - Devcontainer: Can run as root (apt-install feature) or non-root (postCreateCommand)
# - GitHub Actions: Runs as non-root user, auto-detects need for sudo
# Dual-Environment Design:
#
# Works for both GitHub Actions and devcontainer environments
# Setup script for tree-sitter dependencies (Ubuntu/Debian)

set -e

