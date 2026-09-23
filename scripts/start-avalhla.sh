#!/usr/bin/env bash
# start-avalhla.sh — boot container + launch Avalhla
set -Eeuo pipefail

case "${1:-}" in
    -h|--help)
        echo "usage: start-avalhla.sh"
        echo "       start Ollama and launch Avalhla"
        exit 0
        ;;
esac


MODEL=avalhla

echo "🚀 Starting container ollama.service..."
systemctl --user start ollama.service

echo "⏳ Waiting for Ollama to be ready..."
for _ in $(seq 1 30); do
    curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break
    sleep 1
done

if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "❌ Ollama container not responding. Check:"
    echo "   systemctl --user status ollama.service"
    exit 1
fi

echo "✅ Ollama ready"

if ! ollama list 2>/dev/null | awk '{print $1}' | grep -q "^${MODEL}:latest$"; then
    echo "⚠️  Model '$MODEL' not found. Building from persona/avalhla.Modelfile..."
    cd "$HOME/Avalhla"
    ollama create "$MODEL" -f persona/avalhla.Modelfile
fi

echo "💬 Launching $MODEL..."
echo "──────────────────────────────────────────────"
ollama run "$MODEL"
