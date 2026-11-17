#!/bin/bash

source dev-container-features-test-lib
source ./helpers.sh

# Source test scripts
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-scripts"
for f in "$dir"/*.sh; do
    [ -r "$f" ] && source "$f"
done
unset f dir

ALICE_UID="Alice Test <alice@example.test>"
BOB_UID="Bob Test <bob@example.test>"
SCRATCH="$(mktemp -d)"
HOST_GNUPGHOME="${SCRATCH}/host-gnupg"
mkdir -p "$HOST_GNUPGHOME" && chmod 700 "$HOST_GNUPGHOME"

cleanup() {
    GNUPGHOME="$HOST_GNUPGHOME" gpgconf --kill all >/dev/null 2>&1 || true
    rm -rf "$SCRATCH"
}
trap cleanup EXIT

check "gpg is installed" gpg --version
check "gpg-agent is installed" command -v gpg-agent
check "git is available for tests" command -v git

IMPORT_SCRIPT="$(command -v import-gpg-keys.sh || true)"
check "import-gpg-keys.sh is on PATH (postCreateCommand calls it by name)" \
test -n "$IMPORT_SCRIPT"

ALICE_FPR="$(gen_key "$ALICE_UID")"
BOB_FPR="$(gen_key "$BOB_UID")"
check "test keys generated" \
test -n "$ALICE_FPR" -a -n "$BOB_FPR"

check "import: signing key chosen via git email" case_email_match
check "import: single exported key is used as fallback" case_single_key_fallback
check "import: ambiguous keys import, but do not enable signing" case_ambiguous_no_signing
check "import: partial email does not match a key" case_email_requires_whole_address
check "import: meta file without trailing newline" case_meta_without_trailing_newline
check "import: removes temp files afterwards" case_cleans_up
check "import: keys without meta are imported only" case_keys_without_meta
check "import: exits 0 when nothing was exported" case_no_export_files
check "import: exits non-zero on a corrupt key file" case_bad_key_file_fails

reportResults
