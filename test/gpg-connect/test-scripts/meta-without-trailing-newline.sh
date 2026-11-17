#!/bin/bash

# A manually written meta file with no trailing newline still works
case_meta_without_trailing_newline() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID"
    printf '%s\t%s' "$ALICE_FPR" "$ALICE_UID" > "${WS}/tmp/.gpg-export.meta"
    run_import || fail_with "import exited non-zero" || exit 1
    [ "$(git_cfg user.signingkey)" = "$ALICE_FPR" ] || fail_with "single-key fallback failed without trailing newline" || exit 1
)
