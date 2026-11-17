#!/bin/bash

# Keys with no meta file; imported, but signing not configured
case_keys_without_meta() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID"
    rm -f "${WS}/tmp/.gpg-export.meta"
    run_import || fail_with "import exited non-zero" || exit 1
    ctr_has_key "$ALICE_FPR" || fail_with "key was not imported" || exit 1
    [ -z "$(git_cfg commit.gpgsign)" ] || fail_with "signing configured without meta file" || exit 1
)
