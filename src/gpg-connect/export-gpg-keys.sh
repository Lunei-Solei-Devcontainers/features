#!/bin/sh
set -e

echo "Activating feature 'gpg-connect'"

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <repo-dir>" >&2
    exit 1
fi

# Fail early if GPG agent forwarding is unavailable
SOCK=$(gpgconf --list-dirs agent-extra-socket)
if [ ! -S "$SOCK" ]; then
    echo "Error: GPG extra socket not found at $SOCK"
    exit 1
fi

# Temporary output files (removed after import)
TMP_DIR="${1}/tmp"
mkdir -p "${TMP_DIR}"
OUTPUT_FILE="${TMP_DIR}/.gpg-export.gpg"
META_FILE="${TMP_DIR}/.gpg-export.meta"

# Work files (removed on script exit)
RAW_FILE="${TMP_DIR}/.gpg-export.raw"
KEYS_FILE="${TMP_DIR}/.gpg-export.keys"
SEL_FILE="${TMP_DIR}/.gpg-export.sel"

# Cleanup function to remove output files
cleanup_outputs() {
    rm -f "$OUTPUT_FILE" "$META_FILE"
    rmdir "${TMP_DIR}" 2>/dev/null || true
}

cleanup_work() {
    rm -f "$RAW_FILE" "$KEYS_FILE" "$SEL_FILE"
}
trap cleanup_work EXIT

TAB=$(printf '\t')
: > "$KEYS_FILE"
: > "$SEL_FILE"

current_fpr=""
current_uid=""
skip_key=0

# Helper function to save key
save_current_key() {
    if [ -n "$current_fpr" ] && [ -n "$current_uid" ]; then
        printf '%s\t%s\n' "$current_fpr" "$current_uid" >> "$KEYS_FILE"
    fi
}

gpg --list-keys --with-colons 2>/dev/null > "$RAW_FILE" || true

while IFS=: read -r type validity _ _ _ _ _ _ _ fpr_uid _; do
    case "$type" in
        pub)
            # Start of a new key; save the previous key, then reset state.
            save_current_key
            current_fpr=""
            current_uid=""

            # Skip expired (e), revoked (r), invalid (i), and disabled (d) keys
            case "$validity" in
                e|r|i|d) skip_key=1 ;;
                *) skip_key=0 ;;
            esac
            ;;
        fpr)
            # First fingerprint after "pub" is the primary key fingerprint
            if [ "$skip_key" -eq 0 ] && [ -z "$current_fpr" ]; then
                current_fpr="$fpr_uid"
            fi
            ;;
        uid)
            if [ "$skip_key" -eq 0 ] && [ -z "$current_uid" ]; then
                current_uid=$(printf '%s' "$fpr_uid" | sed 's/\\x3a/:/g')
            fi
            ;;
    esac
done < "$RAW_FILE"

# Save the last key
save_current_key

TOTAL=$(wc -l < "$KEYS_FILE" | tr -d ' ')

# Early exit if no keys
if [ "$TOTAL" -eq 0 ]; then
    echo "No usable GPG public keys found on host. Skipping public key import."
    cleanup_outputs
    exit 0
fi

# Display key selection header
echo ""
echo "GPG KEY Selection for DevContainer"
echo "=================================="

# Display key list
echo ""
echo "Keys available on host"
echo ""

n=0
while IFS="$TAB" read -r fpr uid; do
    n=$((n + 1))
    short=$(printf '%s' "$fpr" | awk '{ print substr($0, length($0) - 15) }')
    printf "    %d %s %s\n" "$n" "$short" "$uid"
done < "$KEYS_FILE"

# Prompt for key selection
echo ""
echo "    Enter either individual number(s) to import (space-separated), 'all', or 'none'"
echo "    default: 'all'"
printf "    > "

# Read with a timeout (defaults to all)
SELECTION=""
got_input=1
if command -v timeout >/dev/null 2>&1 && timeout --foreground 1 true >/dev/null 2>&1; then
    if ! SELECTION=$(timeout --foreground 60 sh -c 'IFS= read -r line && printf "%s" "$line"'); then
        got_input=0
    fi
else
    if ! read -r SELECTION; then
        got_input=0
    fi
fi

if [ "$got_input" -eq 0 ]; then
    echo ""
    echo "    No input received. Defaulting to 'all'"
    SELECTION="all"
elif [ -z "$SELECTION" ]; then
    SELECTION="all"
fi

# Process selection
if [ "$SELECTION" = "none" ]; then
    echo ""
    echo "'none' selected. Skipping GPG key import."
    cleanup_outputs
    exit 0
elif [ "$SELECTION" = "all" ]; then
    cp "$KEYS_FILE" "$SEL_FILE"
else
    set -f # no globbing while splitting $SELECTION
    for token in $SELECTION; do
        case "$token" in
            ''|*[!0-9]*)
                echo "    '$token' is not a valid number. Skipping."
                continue
                ;;
        esac
        # Strip leading zeros so the arithmetic is not read as octal
        num=$(printf '%s' "$token" | sed 's/^0*//')
        num=${num:-0}
        if [ "$num" -ge 1 ] && [ "$num" -le "$TOTAL" ]; then
            line=$(sed -n "${num}p" "$KEYS_FILE")
            fpr=$(printf '%s' "$line" | cut -f1)
            # Skip duplicates
            if ! cut -f1 "$SEL_FILE" | grep -qxF "$fpr"; then
                printf '%s\n' "$line" >> "$SEL_FILE"
            fi
        else
            echo "    '$token' is out of range. Skipping."
        fi
    done
    set +f
fi

COUNT=$(wc -l < "$SEL_FILE" | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
    echo ""
    echo "No valid keys selected. Nothing will be imported."
    cleanup_outputs
    exit 0
fi

# Export public keys
echo ""
echo "Exporting ${COUNT} key(s)..."
set --
while IFS="$TAB" read -r fpr _; do
    set -- "$@" "$fpr"
done < "$SEL_FILE"
gpg --export "$@" > "$OUTPUT_FILE"

# Write metadata for each selected key (fingerprint<TAB>uid)
cp "$SEL_FILE" "$META_FILE"

echo "Exported to $OUTPUT_FILE"
echo "Keys will be imported when the container starts."
echo ""
