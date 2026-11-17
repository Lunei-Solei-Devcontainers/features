#!/bin/bash

# Email that is only a substring of a UID's address must not match
case_email_requires_whole_address() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID" "$BOB_FPR" "$BOB_UID"

    # Use a substring of 'alice'
    HOME="$HOME_DIR" git config --global user.email "ali@example.test"
    run_import || fail_with "import exited non-zero" || exit 1
    [ -z "$(git_cfg user.signingkey)" ] || fail_with "partial email matched a key" || exit 1
)
