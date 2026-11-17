#!/bin/bash

# One key exported with no set email; that single key is used
case_single_key_fallback() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID"
    run_import || fail_with "import exited non-zero" || exit 1
    [ "$(git_cfg user.signingkey)" = "$ALICE_FPR" || fail_with "signingkey is '$(git_cfg user.signingkey)', want $ALICE_FPR" || exit 1
    [ "$(git_cfg commit.gpgsign)" = "true" ] || fail_with "commit.gpgsign not true" || exit 1
)
