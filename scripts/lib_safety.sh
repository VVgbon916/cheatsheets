#!/usr/bin/env bash
# =============================================================================
# lib_safety.sh
#
# Deterministic Avalhla safety boundary.
#
# This file intentionally does NOT ask an LLM whether an operation is safe.
# Policy lives here, outside the model.
#
# Safe defaults:
#   read                  = bounded
#   inference            = bounded
#   memory write         = bounded
#   local Ollama API     = allowed
#   external network     = denied
#   arbitrary shell      = denied
#   system mutation      = denied
#   external side effect = denied
# =============================================================================

set -Eeuo pipefail

# ---------------------------------------------------------------------------
# Capability policy
# ---------------------------------------------------------------------------

ava_safety_capability() {
    case "${1:-}" in
        read)
            return 0
            ;;
        inference)
            return 0
            ;;
        memory-write)
            return 0
            ;;
        local-api)
            return 0
            ;;
        external-network|shell|system-mutation|external-side-effect)
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Canonical path helpers
# ---------------------------------------------------------------------------

ava_safety_realpath() {
    realpath -e -- "$1" 2>/dev/null
}

ava_safety_under() {
    local child root

    # Targets may not exist yet.  The old implementation used
    # realpath -e and therefore rejected legitimate future files.
    # realpath -m canonicalizes the complete lexical path while
    # resolving existing symlink components.
    child="$(realpath -m -- "$1" 2>/dev/null || true)"
    root="$(realpath -m -- "$2" 2>/dev/null || true)"

    [[ -n "$child" && -n "$root" ]] || return 1

    [[ "$child" == "$root" || "$child" == "$root/"* ]]
}

# ---------------------------------------------------------------------------
# Sensitive-file denylist
#
# This is deliberately conservative.
# A file can be inside an otherwise trusted directory and still be unsafe
# to place into model context.
# ---------------------------------------------------------------------------

ava_safety_sensitive() {
    local path base

    # A destination may not exist yet.  Security classification must
    # still work for future files, so canonicalize lexically rather
    # than treating "does not exist" as "sensitive".
    path="$(realpath -m -- "$1" 2>/dev/null || true)"
    [[ -n "$path" ]] || return 0

    base="$(basename "$path")"

    case "$base" in
        .env|.env.*)
            return 0
            ;;
        .netrc|.npmrc|.pypirc)
            return 0
            ;;
        .dockerconfigjson)
            return 0
            ;;
        credentials|credentials.*)
            return 0
            ;;
        service-account*.json)
            return 0
            ;;
        *secret*.json|*secret*.yaml|*secret*.yml)
            return 0
            ;;
        *token*.json|*token*.yaml|*token*.yml)
            return 0
            ;;
        id_rsa|id_rsa.*|id_ed25519|id_ed25519.*)
            return 0
            ;;
        *.pem|*.key|*.p12|*.pfx)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Security audit log
#
# We record WHAT happened without recording raw file contents.
# Target is represented by a SHA-256 path fingerprint.
# ---------------------------------------------------------------------------

ava_safety_audit() {
    local action="${1:-unknown}"
    local result="${2:-unknown}"
    local target="${3:-}"

    local audit_dir="${AVA_SAFETY_AUDIT_DIR:-$AVA_REALITY_DIR/security}"
    local audit_file="$audit_dir/events.jsonl"
    local target_hash=""

    mkdir -p "$audit_dir"
    chmod 700 "$audit_dir"

    if [[ -n "$target" ]]; then
        target_hash="$(
            printf '%s' "$target" |
                sha256sum |
                awk '{print $1}'
        )"
    fi

    jq -cn \
        --arg ts "$(date -Iseconds)" \
        --arg action "$action" \
        --arg result "$result" \
        --arg target_hash "$target_hash" \
        --arg pid "$$" \
        '{
            ts:$ts,
            action:$action,
            result:$result,
            target_hash:$target_hash,
            pid:($pid|tonumber)
        }' >> "$audit_file"

    chmod 600 "$audit_file"
}

# ---------------------------------------------------------------------------
# READ boundary
# ---------------------------------------------------------------------------

ava_safety_assert_readable() {
    local target="$1"
    local real

    real="$(ava_safety_realpath "$target")" || {
        ava_safety_audit "read" "deny-not-found" "$target"
        echo "X safety: target does not resolve" >&2
        return 1
    }

    if ava_safety_sensitive "$real"; then
        ava_safety_audit "read" "deny-sensitive" "$real"
        echo "X safety: sensitive file denied" >&2
        return 1
    fi

    ava_safety_audit "read" "allow" "$real"
    return 0
}

# ---------------------------------------------------------------------------
# LEARN / INDEX boundary
#
# Learning may only originate from:
#   - Avalhla repo
#   - auto-read dropbox
#   - existing knowledge-base
#
# It may NOT arbitrarily walk the user's home directory, /etc, /var, etc.
# ---------------------------------------------------------------------------

ava_safety_assert_learn_source() {
    local target="$1"
    local real

    real="$(ava_safety_realpath "$target")" || {
        ava_safety_audit "learn-source" "deny-not-found" "$target"
        echo "X safety: learning source does not resolve" >&2
        return 1
    }

    if ava_safety_sensitive "$real"; then
        ava_safety_audit "learn-source" "deny-sensitive" "$real"
        echo "X safety: sensitive learning source denied" >&2
        return 1
    fi

    if ava_safety_under "$real" "$AVA_ROOT" ||
       ava_safety_under "$real" "$AVA_AUTOREAD_DIR" ||
       ava_safety_under "$real" "$AVA_KNOWLEDGE_DIR"; then
        ava_safety_audit "learn-source" "allow" "$real"
        return 0
    fi

    ava_safety_audit "learn-source" "deny-outside-root" "$real"
    echo "X safety: learning source outside approved roots" >&2
    return 1
}

ava_safety_assert_learn_file() {
    local target="$1"

    if ava_safety_sensitive "$target"; then
        ava_safety_audit "learn-file" "deny-sensitive" "$target"
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# MEMORY WRITE boundary
# ---------------------------------------------------------------------------

ava_safety_assert_memory_write() {
    local target="$1"
    local real root_real

    real="$(realpath -m -- "$target" 2>/dev/null || true)"
    root_real="$(realpath -m -- "$AVA_MEMORY_DIR" 2>/dev/null || true)"

    [[ -n "$real" && -n "$root_real" ]] || {
        ava_safety_audit "memory-write" "deny-unresolved" "$target"
        echo "X safety: memory write path does not resolve" >&2
        return 1
    }

    if ! ava_safety_under "$real" "$root_real"; then
        ava_safety_audit "memory-write" "deny-outside-memory" "$real"
        echo "X safety: memory write outside memory root" >&2
        return 1
    fi

    if ava_safety_sensitive "$real"; then
        ava_safety_audit "memory-write" "deny-sensitive" "$real"
        echo "X safety: sensitive memory target denied" >&2
        return 1
    fi

    ava_safety_audit "memory-write" "allow" "$real"
    return 0
}

ava_safety_assert_ingest_source() {
    local target="$1"
    local real

    real="$(ava_safety_realpath "$target")" || {
        ava_safety_audit "ingest-source" "deny-not-found" "$target"
        echo "X safety: ingest source does not resolve" >&2
        return 1
    }

    if ava_safety_sensitive "$real"; then
        ava_safety_audit "ingest-source" "deny-sensitive" "$real"
        echo "X safety: sensitive ingest denied" >&2
        return 1
    fi

    ava_safety_audit "ingest-source" "allow" "$real"
    return 0
}

ava_safety_write_file() {
    local target="$1"
    local content="$2"

    ava_safety_assert_memory_write "$target" || return 1

    local parent
    parent="$(dirname "$target")"
    mkdir -p -- "$parent"

    ava_safety_assert_memory_write "$target" || return 1

    printf '%s' "$content" > "$target"
    ava_safety_audit "memory-write" "commit" "$target"
}

ava_safety_append_file() {
    local target="$1"
    local content="$2"

    ava_safety_assert_memory_write "$target" || return 1

    local parent
    parent="$(dirname "$target")"
    mkdir -p -- "$parent"

    ava_safety_assert_memory_write "$target" || return 1

    printf '%s' "$content" >> "$target"
    ava_safety_audit "memory-append" "commit" "$target"
}

# ---------------------------------------------------------------------------
# SELF TEST
# ---------------------------------------------------------------------------

ava_safety_self_test() {
    local failures=0
    local tmp

    printf '%s\n' '-- safety capability matrix --'

    for cap in read inference memory-write local-api; do
        if ava_safety_capability "$cap"; then
            printf '  [ OK ] allow %s\n' "$cap"
        else
            printf '  [FAIL] allow %s\n' "$cap"
            failures=$((failures + 1))
        fi
    done

    for cap in external-network shell system-mutation external-side-effect; do
        if ava_safety_capability "$cap"; then
            printf '  [FAIL] deny %s\n' "$cap"
            failures=$((failures + 1))
        else
            printf '  [ OK ] deny %s\n' "$cap"
        fi
    done

    tmp="$(mktemp -d)"

    printf 'safe\n' > "$tmp/safe.txt"
    printf 'secret\n' > "$tmp/.env"
    printf 'key\n' > "$tmp/id_ed25519"

    if ava_safety_sensitive "$tmp/safe.txt"; then
        printf '  [FAIL] ordinary file accepted\n'
        failures=$((failures + 1))
    else
        printf '  [ OK ] ordinary file accepted\n'
    fi

    if ava_safety_sensitive "$tmp/.env"; then
        printf '  [ OK ] .env denied\n'
    else
        printf '  [FAIL] .env denied\n'
        failures=$((failures + 1))
    fi

    if ava_safety_sensitive "$tmp/id_ed25519"; then
        printf '  [ OK ] private key denied\n'
    else
        printf '  [FAIL] private key denied\n'
        failures=$((failures + 1))
    fi

    rm -rf "$tmp"

    if (( failures == 0 )); then
        printf '%s\n' 'result: SAFETY SELF-TEST CLEAN'
        return 0
    fi

    printf 'result: %d SAFETY FAILURE(S)\n' "$failures"
    return 1
}
