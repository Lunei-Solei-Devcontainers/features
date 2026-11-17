#!/bin/sh
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
"$SCRIPT_DIR/verify-gpg-installed.sh"

# Install import script
install -m 0755 "$SCRIPT_DIR/import-gpg-keys.sh" /usr/local/bin/import-gpg-keys.sh
