#!/bin/bash

# Two keys, git email matches neither; keys are imported but signing is NOT configured, and the user is told how to choose a key
case_ambiguous_no_signing() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID" "$BOB_FPR" "$BOB_UID"
    HOME="$HOME_DIR" git config --global user.email "nobody@example.test"
    run_import || fail_with "import exited non-zero" || exit 1
    [ -z "$(git_cfg user.signingkey)" ] || fail_with "signingkey should be unset, got '$(git_cfg user.signingkey)'" |\ exit 1
    [ -z "$(git_cfg commit.gpgsign)" ] || fail_with "commit.gpgsign should be unset" || exit 1
    grep -q "could not determine a unique signing key" "${WS}/../import.log" || fail_with "no warning printed" || exit 1
    ctr_has_key "$ALICE_FPR" && ctr_has_key "$BOB_FPR" || fail_with "keys were not imported" || exit 1
)
