#!/bin/bash
# review-cheatsheets.sh — lint the repo for banned/deprecated patterns.
# Run from repo root:  ./scripts/review-cheatsheets.sh

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

echo "════════════════════════════════════════════════════════════"
echo "  Cheatsheets review — $(pwd)"
echo "════════════════════════════════════════════════════════════"

hr() { printf '─%.0s' {1..64}; echo; }

hr; echo "📌 Files mentioning 'sudo ' (info):"; hr
grep -rl --include="*.md" -e 'sudo ' . 2>/dev/null || echo "  (none)"

hr; echo "📌 Files referencing allowed layered packages:"; hr
allowed=(coolercontrol liquidctl mangohud topgrade gh)
for pkg in "${allowed[@]}"; do
    matches=$(grep -rl --include="*.md" -e "$pkg" . 2>/dev/null || true)
    [[ -n "$matches" ]] && echo "  [$pkg]" && echo "$matches" | sed 's/^/    /'
done

hr; echo "🚫 Files with banned host package managers:"; hr
banned=("sudo apt" "sudo dnf" "sudo pacman" "sudo zypper")
found_banned=0
for cmd in "${banned[@]}"; do
    matches=$(grep -rl --include="*.md" -e "$cmd" . 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
        found_banned=1
        echo "  [$cmd]"
        echo "$matches" | sed 's/^/    /'
    fi
done
[[ $found_banned -eq 0 ]] && echo "  ✅ none"

hr; echo "⚠️  Obsolete / known-broken patterns:"; hr
obsolete=(
    "DXVK_ASYNC=1"
    "btrfs filesystem usage /"
    "nvidia-persistenced --query"
    "rpm-ostree commit"
    "distrobox-export --app cava"
    "java-17-openjdk-devel"
    "java-21-openjdk-devel"
)
for pat in "${obsolete[@]}"; do
    matches=$(grep -rl --include="*.md" -F -e "$pat" . 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
        echo "  ⚠  [$pat]"
        echo "$matches" | sed 's/^/      /'
    fi
done

hr; echo "🔒 Secret leak check (should be empty):"; hr
grep -rInE '(ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|BEGIN (RSA|OPENSSH|ED25519) PRIVATE KEY|password[[:space:]]*=[[:space:]]*[^ ])' \
    --include="*.md" --include="*.sh" --include="*.txt" . 2>/dev/null \
    | grep -v '\.example:' \
    || echo "  ✅ no secrets found"

hr; echo "🔒 Verify private/ is gitignored:"; hr
for f in private/D42k.md private/Dawa.txt; do
    if [[ -e "$f" ]]; then
        if git check-ignore -q "$f"; then
            echo "  ✅ $f is gitignored"
        else
            echo "  🔴 $f is NOT gitignored — FIX NOW"
        fi
    fi
done

hr; echo "Done."; hr
