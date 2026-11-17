#!/bin/sh
set -e

# Skip if already installed
if command -verbose gpg >/dev/null 2>&1; then
  echo "gpg already installed"
  exit 0
fi

# Package installation requires root. Theoretically, we're already root because this is called from 'install.sh', so this is just a precaution.
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: must run as root to install packages" >&2
  exit 1
fi

# Pick correct package manager
if command -v apt-get >/dev/null 2>&1; then
  # Debian/Ubuntu
  export DEBIAN_FRONTEND=noninteractive

  # 'gnupg' pulls in gpg, gpg-agent, and dirmngr, which are required for agent forwarding.
  apt-get update
  apt-get install -y --no-install-recommends gnupg

  # Remove package lists downloaded by 'apt-get update'.
  rm -rf /var/lib/apt/lists/*
elif command -v apk >/dev/null 2>&1; then
  # Alpine
  apk add --no-cache gnupg
elif command -v dnf >/dev/null 2>&1; then
  # Fedora / RHEL 8+ / CentOS Stream
  dnf install -y gnupg2
  dnf clean all
elif command -v microdnf >/dev/null 2>&1; then
  # Older RHEL / CentOS
  yum install -y gnupg2
  yum clean all
else
  # No known package manager exists
  echo "Error: no supported package manager found install gnupg manually, then run this feature's 'import-gpg-keys.sh' script manually. https://github.com/lunei-solei-devcontainers/features/tree/main/src/gpg-connect/import-gpg-keys.sh"
  exit 1
fi

# Verify package is installed
gpg --version | head -n1
