#!/bin/bash
echo "╭──────────────────────────────────────────────╮"
echo "│           🐧 SYSTEM SNAPSHOT                │"
echo "╰──────────────────────────────────────────────╯"
echo ""
echo "📅 Date:        $(date '+%Y-%m-%d %H:%M')"
echo "💻 Hostname:    $(hostname)"
echo "🐧 OS:          $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
echo "🧠 Kernel:      $(uname -r)"
echo ""
echo "── 🖼️  DEPLOYMENT ─────────────────"
rpm-ostree status | grep -E "●|Commit|Deployments" | head -n 5
echo ""
echo "── 📦 FLATPAKS ────────────────"
flatpak list --app --columns=name,version | head -n 20
echo ""
echo "── 🍺 HOMEBREW ────────────────"
brew list --formula | head -n 20
echo ""
echo "── 🐳 DISTROBOX ───────────────"
distrobox list --no-color
echo ""
echo "── 🧠 OLLAMA ──────────────────"
ollama list
echo ""
echo "──────────────────────────────"
echo "Snapshot complete."
