#!/bin/bash

# Corrupt key file; must fail loudly
case_bad_key_file_fails() (
    new_sandbox
    mkdir -p "${WS}/tmp"
    echo "this is not a key" > "${WS}/tmp/.gpg-export.gpg"
    if run_import; then
        fail_with "import should exit non-zero for a corrupt key file"
        exit 1
    fi
    grep -q "gpg import failed" "${WS}/../import.log" || fail_with "failure was not reported by the script" || exit 1
    [ -z "$(git_cfg commit.gpgsign)" ] || fail_with "signing configured after failed import" || exit 1
)
