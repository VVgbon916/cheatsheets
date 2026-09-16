SHELL := /bin/bash
.DEFAULT_GOAL := help

SCRIPTS   := scripts
AI_DIR    := ai
MODEL     := deepseek-r1-tool-14b-16k
BASE      := deepseek-r1:14b

BOLD  := \033[1m
DIM   := \033[2m
GREEN := \033[32m
YELLOW:= \033[33m
CYAN  := \033[36m
RESET := \033[0m

.PHONY: help
help:
	@echo ""
	@echo -e "  $(BOLD)$(CYAN)VVgBazz toolkit$(RESET)  $(DIM)— type one word, get one job done$(RESET)"
	@echo ""
	@echo -e "  $(BOLD)START HERE$(RESET)"
	@echo -e "    $(GREEN)make verify$(RESET)      check everything before you work"
	@echo -e "    $(GREEN)make fix$(RESET)         auto-repair what's safe to fix"
	@echo -e "    $(GREEN)make ai$(RESET)          talk to Avalhla"
	@echo ""
	@echo -e "  $(BOLD)AI / OLLAMA$(RESET)"
	@echo -e "    $(GREEN)make ctx-16k$(RESET)     restart Ollama at 16K (daily driver)"
	@echo -e "    $(GREEN)make ctx-32k$(RESET)     restart Ollama at 32K (long jobs)"
	@echo -e "    $(GREEN)make ai-status$(RESET)   is the server up? what's loaded?"
	@echo -e "    $(GREEN)make ai-stop$(RESET)     unload the model from VRAM"
	@echo -e "    $(GREEN)make ai-rebuild$(RESET)  rebuild the agent model from Modelfile"
	@echo -e "    $(GREEN)make ai-log$(RESET)      tail the server log"
	@echo ""
	@echo -e "  $(BOLD)SYSTEM$(RESET)"
	@echo -e "    $(GREEN)make health$(RESET)      full read-only system report"
	@echo -e "    $(GREEN)make update$(RESET)      check for OS + app updates"
	@echo -e "    $(GREEN)make gpu$(RESET)         NVIDIA status"
	@echo -e "    $(GREEN)make audio$(RESET)       PipeWire sinks/sources"
	@echo -e "    $(GREEN)make net$(RESET)         network status"
	@echo -e "    $(GREEN)make logs$(RESET)        recent errors"
	@echo ""
	@echo -e "  $(BOLD)DEV$(RESET)"
	@echo -e "    $(GREEN)make lab$(RESET)         enter the coding-lab container"
	@echo -e "    $(GREEN)make tools$(RESET)       verify coding-lab dependencies"
	@echo ""
	@echo -e "  $(BOLD)REPO$(RESET)"
	@echo -e "    $(GREEN)make review$(RESET)      lint the repo for banned patterns"
	@echo -e "    $(GREEN)make status$(RESET)      git status, short"
	@echo -e "    $(GREEN)make push$(RESET)        commit + push (asks for message)"
	@echo -e "    $(GREEN)make pull$(RESET)        pull latest"
	@echo ""
	@echo -e "  $(BOLD)PRIVATE$(RESET)  $(DIM)(local only — never pushed)$(RESET)"
	@echo -e "    $(GREEN)make bible$(RESET)       open D42k.md (the Bible)"
	@echo -e "    $(GREEN)make keys$(RESET)        open Dawa.txt (credentials)"
	@echo ""

.PHONY: verify
verify:
	@$(SCRIPTS)/verify-before-work.sh

.PHONY: fix
fix:
	@$(SCRIPTS)/verify-before-work.sh --fix

.PHONY: ai
ai:
	@echo "→ launching Avalhla..."
	@$(SCRIPTS)/ai-with-memory

.PHONY: ctx-16k
ctx-16k:
	@$(SCRIPTS)/ollama-ctx 16384

.PHONY: ctx-32k
ctx-32k:
	@$(SCRIPTS)/ollama-ctx 32768

.PHONY: ctx-8k
ctx-8k:
	@$(SCRIPTS)/ollama-ctx 8192

.PHONY: ai-status
ai-status:
	@echo "→ ollama server:"
	@curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && echo "   ✓ up" || echo "   ✗ down  (run: make ctx-16k)"
	@echo "→ loaded models:"
	@ollama ps 2>/dev/null || true
	@echo "→ context length:"
	@pgrep -af llama-server 2>/dev/null | grep -o '\-c [0-9]*' | head -1 || echo "   (no server running)"

.PHONY: ai-stop
ai-stop:
	@ollama stop $(MODEL) 2>/dev/null && echo "✓ model unloaded" || echo "· nothing to stop"

.PHONY: ai-rebuild
ai-rebuild:
	@if [ ! -f ~/ollama-agent/Modelfile ]; then echo "✗ no Modelfile at ~/ollama-agent/Modelfile"; exit 1; fi
	@cd ~/ollama-agent && ollama create $(MODEL) -f Modelfile

.PHONY: ai-log
ai-log:
	@tail -f ~/.ollama/serve.log

.PHONY: ai-pull
ai-pull:
	@ollama pull $(BASE)

.PHONY: health
health:
	@$(SCRIPTS)/bazzite-toolkit.sh health

.PHONY: update
update:
	@echo "→ OS updates:"
	@rpm-ostree upgrade --check 2>&1 | sed 's/^/   /'
	@echo ""
	@echo "→ Flatpak updates:"
	@flatpak remote-ls --updates 2>/dev/null | sed 's/^/   /' || echo "   (none)"

.PHONY: gpu
gpu:
	@nvidia-smi --query-gpu=name,driver_version,temperature.gpu,power.draw,memory.used,memory.total --format=csv,noheader 2>/dev/null | sed 's/^/  /' || echo "  ✗ nvidia-smi not available"

.PHONY: audio
audio:
	@echo "→ services:"
	@for s in pipewire pipewire-pulse wireplumber; do systemctl --user is-active --quiet $$s && echo "   ✓ $$s" || echo "   ✗ $$s"; done
	@echo "→ sinks:"
	@pactl list short sinks 2>/dev/null | sed 's/^/   /'

.PHONY: net
net:
	@ip -brief addr show | sed 's/^/  /'

.PHONY: logs
logs:
	@journalctl -p err --since "1 hour ago" --no-pager -q 2>/dev/null | tail -20 | sed 's/^/  /' || echo "  (no errors)"

.PHONY: lab
lab:
	@echo "→ entering coding-lab (type 'exit' to leave)..."
	@distrobox enter coding-lab

.PHONY: tools
tools:
	@$(SCRIPTS)/avalhla_tools_check.sh

.PHONY: review
review:
	@$(SCRIPTS)/review-cheatsheets.sh

.PHONY: status
status:
	@git status -sb
	@echo ""
	@git log --oneline -5

.PHONY: push
push:
	@read -p "commit message: " msg; \
	if [ -z "$$msg" ]; then echo "✗ aborted — no message"; exit 1; fi; \
	git add -A && git commit -m "$$msg" && git push && echo "✓ pushed"

.PHONY: pull
pull:
	@git pull --rebase && echo "✓ up to date"

.PHONY: bible
bible:
	@if [ -f private/D42k.md ]; then less private/D42k.md; else echo "✗ private/D42k.md not found"; fi

.PHONY: keys
keys:
	@if [ -f private/Dawa.txt ]; then echo "⚠ opening credentials"; less private/Dawa.txt; else echo "✗ private/Dawa.txt not found"; fi
