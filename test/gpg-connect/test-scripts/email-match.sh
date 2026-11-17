#!/bin/bash

# Two keys exported; git email matches the second one, case-insensitive
case_email_match() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID" "$BOB_FPR" "$BOB_UID"
    HOME="$HOME_DIR" git config --global user.email "BOB@Example.Test"
    run_import || fail_with "import exited non-zero" || exit 1
    [ "$(git_cfg user.signingkey)" = "$BOB_FPR" ] || fail_with "signingkey is '$(git_cfg user.signingkey)', want Bob's $BOB_FPR" || exit 1
    [ "$(git_cfg commit.gpgsign)" = "true" ] || fail_with "commit.gpgsign not true" || exit 1
    [ "$(git_cfg tag.gpgsign)" = "true" ] || fail_with "tag.gpgsign not true" || exit 1
    ctr_has_key "$ALICE_FPR" && ctr_has_key "$BOB_FPR" || fail_with "keys were not imported" || exit 1
)
