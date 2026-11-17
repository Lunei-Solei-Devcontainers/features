#!/bin/bash

# Helpers

# gen_key <uid>
# Prints the new key's primary fingerprint.
gen_key() {
    GNUPGHOME="$HOST_GNUPGHOME" gpg --batch --quiet --passphrase '' \
        --quick-generate-key "$1" ed25519 sign never >/dev/null 2>&1 || return 1
    GNUPGHOME="$HOST_GNUPGHOME" gpg --list-keys --with-colons "$1" \
        | awk -F: '$1 == "fpr" { print $10; exit }'
}

# stage_export <workspace> <fpr> <uid> [<fpr> <uid> ...]
# Writes <workspace>/tmp/.gpg-export.{gpg, meta} like the export script does.
stage_export() {
    local ws="$1"; shift
    local fprs="" meta=""
    mkdir -p "${ws}/tmp"
    while [ "$#" -ge 2 ]; do
        fprs="${fprs} $1"
        meta="${meta}$(printf '%s\t%s\n' "$1" "$2")"$'\n'
        shift 2
    done

    GNUPGHOME="$HOST_GNUPGHOME" gpg --export $fprs > "${ws}/tmp/.gpg-export.gpg"
    printf '%s' "$meta" > "${ws}/tmp/.gpg-export.meta"
}

# new_sandbox
# Sets WS, HOME_DIR, CTR_GNUPGHOME for the calling subshell.
new_sandbox() {
    local d
    d="$(mktemp -d "${SCRATCH}/case.XXXXXX")"
    WS="${d}/workspace"
    HOME_DIR="${d}/home"
    CTR_GNUPGHOME="${d}/ctr-gnupg"
    mkdir -p "$WS" "$HOME_DIR" "$CTR_GNUPGHOME"
    chmod 700 "$CTR_GNUPGHOME"
}

# run_import
# Run the feature's postCreateCommand from the workspace directory in an isolated HOME/GNUPGHOME.
run_import() {
    ( cd "$WS" && HOME="$HOME_DIR" GNUPGHOME="$CTR_GNUPGHOME" sh "$IMPORT_SCRIPT" ) \
        >"${WS}/../import.log" 2>&1
}

git_cfg() {
    HOME="$HOME_DIR" git config --global --get "$1" 2>/dev/null || true
}

ctr_has_key() {
    GNUPGHOME="$CTR_GNUPGHOME" gpg --list-keys --with-colons "$1" 2>/dev/null | grep -q "^fpr:::::::::$1:"
}

fail_with() {
    echo "    ASSERT FAILED: $*" >&2
    [ -f "${WS:-/nonexistent}/../import.log" ] && sed 's/^/ | /' "${WS}/../import.log" >&2
    return 1
}
