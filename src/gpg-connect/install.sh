#!/bin/sh
set -e

# Verify GPG is installed
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
"$SCRIPT_DIR/verify-gpg-installed.sh"

# Have remote user take ownership of ~/.gnupg
GNUPG_HOME="$_REMOTE_USER_HOME/.gnupg"
mkdir -p "$GNUPG_HOME"
chown "$_REMOTE_USER":"$(id -gn "$_REMOTE_USER")" "$GNUPG_HOME"
chmod 700 "$GNUPG_HOME"

echo "Remote User:"
echo "    username = $_REMOTE_USER"
echo "    home = $_REMOTE_USER_HOME"
ls -ld "$_REMOTE_USER_HOME" "$_REMOTE_USER_HOME/.gnupg"
stat -c '%U:%G %u:%g %a %n' "$GNUPG_HOME"

# Install import script
install -m 0755 "$SCRIPT_DIR/import-gpg-keys.sh" /usr/local/bin/import-gpg-keys.sh