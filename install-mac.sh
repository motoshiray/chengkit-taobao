#!/bin/sh
# macOS counterpart of Install.ps1. Same steps, same official npm source, same isolated directories.
# Usage: sh install-mac.sh            (download OpenCLI 2.0.2, then configure)
#        sh install-mac.sh --skip-download
set -eu
root=$(cd "$(dirname "$0")" && pwd)

node_bin=$(command -v node) || { echo 'Node.js 22 or newer is required (not found in PATH).' >&2; exit 1; }
major=$("$node_bin" -p 'process.versions.node.split(".")[0]')
if [ "$major" -lt 22 ]; then echo 'Node.js 22 or newer is required.' >&2; exit 1; fi

if [ "${1:-}" != "--skip-download" ]; then
  npm_bin=$(command -v npm) || { echo 'npm not found in PATH.' >&2; exit 1; }
  "$npm_bin" install --prefix "$root/runtime/managed/2.0.2" '@jackwener/opencli@2.0.2' \
    --ignore-scripts --no-audit --no-fund --registry=https://registry.npmjs.org \
    || { echo 'OpenCLI download failed; existing data preserved.' >&2; exit 1; }
fi

"$node_bin" "$root/scripts/configure.cjs" || { echo 'Configuration failed.' >&2; exit 1; }
"$node_bin" "$root/tools/opencli-launch.cjs" doctor || true
echo 'Next: enable the official Chrome extension, then run: node scripts/bind-browser.cjs'
