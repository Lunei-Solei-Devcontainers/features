#!/bin/bash

# Nothing exported; a clean no-op, exit 0, must not break container creation
case_no_export_files() (
    new_sandbox
    run_import || fail_with "import should exit 0 when there is nothing to import" || exit 1
    [ -z "$(git_cfg user.signingkey)" ] || fail_with "git configured with nothing to import" || exit 1
)
