#!/bin/bash

# Tmp files are removed after import
case_cleans_up() (
    new_sandbox
    stage_export "$WS" "$ALICE_FPR" "$ALICE_UID"
    run_import || fail_with "import exited non-zero" || exit 1
    [ ! -e "${WS}/tmp" ] || fail_with "tmp dir still exists: $(ls -A "${WS}/tmp")" || exit 1
)
