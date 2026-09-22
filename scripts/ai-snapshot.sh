#!/bin/bash
# AI-Readable System Snapshot for Bazzite (slim)
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

rpm-ostree status --json 2>/dev/null \
  | jq '{booted: (.deployments[] | select(.booted == true) | {osname, version, checksum, timestamp}), staged: (.deployments[] | select(.staged == true) | {version, checksum} // null), deployment_count: (.deployments | length)}' >"$TMP/rpm_ostree.json" 2>/dev/null || echo '{}' >"$TMP/rpm_ostree.json"
flatpak list --app --json 2>/dev/null | jq 'map({name, version, origin})' >"$TMP/flatpak.json" || echo '[]' >"$TMP/flatpak.json"
brew list --formula 2>/dev/null | jq -R -s 'split("\n") | map(select(length>0))' >"$TMP/brew.json" || echo '[]' >"$TMP/brew.json"
distrobox list --no-color 2>/dev/null | tail -n +2 | awk -F'|' '{gsub(/^ +| +$/, "", $2); gsub(/^ +| +$/, "", $3); gsub(/^ +| +$/, "", $4); print $2"|"$3"|"$4}' | jq -R -s 'split("\n") | map(select(length>0) | split("|") | {name: .[0], status: .[1], image: .[2]})' >"$TMP/distrobox.json" || echo '[]' >"$TMP/distrobox.json"
ollama list 2>/dev/null | tail -n +2 | awk '{print $1"|"$3" "$4}' | jq -R -s 'split("\n") | map(select(length>0) | split("|") | {name: .[0], size: .[1]})' >"$TMP/ollama.json" || echo '[]' >"$TMP/ollama.json"

jq -n \
  --arg hostname "$(hostname)" --arg date "$(date -Iseconds)" \
  --arg os "$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)" \
  --arg kernel "$(uname -r)" \
  --slurpfile rpm_ostree "$TMP/rpm_ostree.json" \
  --slurpfile flatpak "$TMP/flatpak.json" \
  --slurpfile brew "$TMP/brew.json" \
  --slurpfile distrobox "$TMP/distrobox.json" \
  --slurpfile ollama "$TMP/ollama.json" \
  '{hostname: $hostname, timestamp: $date, os: $os, kernel: $kernel, deployment: $rpm_ostree[0], flatpaks: $flatpak[0], homebrew_formulas: $brew[0], distrobox_containers: $distrobox[0], ollama_models: $ollama[0]}'
