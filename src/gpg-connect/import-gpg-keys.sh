#!/bin/sh

# Usage: ./install.sh <workspace-folder-name>
set -e

echo "Attempting to import GPG keys."

: "${1:?Usage: $0 <workspace-folder-name>}"

TMP_DIR="${PWD}/tmp"
KEY_FILE="${TMP_DIR}/.gpg-export.gpg"
META_FILE="${TMP_DIR}/.gpg-export.meta"

if [ ! -f "$KEY_FILE" ]; then
    echo "No exported GPG keys found at $KEY_FILE. Skipping GPG key import."
    exit 0
fi

echo "Importing GPG keys from $KEY_FILE." >&2

if ! gpg --import "$KEY_FILE"; then
    echo "Warning: gpg import failed for $KEY_FILE." >&2
    exit 1
fi

echo "GPG keys imported."

# Determine signing key
if [ -f "$META_FILE" ]; then
    GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
    SIGNING_KEY=""

    # Match the git email against the key UIDs (case-insensitive, literal match)
    if [ -n "$GIT_EMAIL" ]; then
        SIGNING_KEY="$(EMAIL="$GIT_EMAIL" awk -F'\t' \
        'BEGIN { e = tolower("<" ENVIRON["EMAIL"] ">") } 
        index(tolower($2), e) { print $1; exit }' "$META_FILE")"
    fi

    # Fallback: only one key imported (awk counts a final line with no newline)
    if [ -z "$SIGNING_KEY" ] && [ "$(awk 'END { print NR }' "$META_FILE")" -eq 1 ]; then
        SIGNING_KEY="$(cut -f1 "$META_FILE" | head -n1)"
    fi

    if [ -n "$SIGNING_KEY" ]; then
        git config --global user.signingkey "$SIGNING_KEY"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        git config --global gpg.program gpg
        echo "Configured git to sign commits with key: $SIGNING_KEY"
    else
        {
            echo "Warning: could not determine a unique signing key automatically."
            echo "Available keys:"
            cat "$META_FILE"
            echo "Set one manually inside the container either with 'git config --global user.signingkey <FPR>' or through your IDE's settings."
        } >&2
    fi

    rm -f "$META_FILE"
fi

# Clean up temporary files
echo "Removing temporary file: $KEY_FILE"
rm -f "$KEY_FILE"
echo "Removing temporary directory: ${TMP_DIR}"
rmdir "${TMP_DIR}" 2>/dev/null || true
