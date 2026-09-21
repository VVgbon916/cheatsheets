SHELL := /bin/bash
.DEFAULT_GOAL := help

SCRIPTS := scripts
MODEL   := avalhla
BASE    := qwen2.5-coder:7b

BOLD   := \033[1m
DIM    := \033[2m
GREEN  := \033[32m
YELLOW := \033[33m
CYAN   := \033[36m
RED    := \033[31m
RESET  := \033[0m

.PHONY: help
help:
	@echo ""
	@echo -e "  $(BOLD)$(CYAN)VVgBazz toolkit$(RESET)  $(DIM)type one word, get one job done$(RESET)"
	@echo ""
	@echo -e "  $(BOLD)START HERE$(RESET)"
	@echo -e "    $(GREEN)make verify$(RESET)      check everything before you work"
	@echo -e "    $(GREEN)make fix$(RESET)         auto-repair what is safe to fix"
	@echo -e "    $(GREEN)make ai$(RESET)          talk to Avalhla"
	@echo ""
	@echo -e "  $(BOLD)OLLAMA CONTAINER$(RESET)"
	@echo -e "    $(GREEN)make ava-start$(RESET)   start ollama.service"
	@echo -e "    $(GREEN)make ava-stop$(RESET)    stop ollama.service (frees VRAM)"
	@echo -e "    $(GREEN)make ava-status$(RESET)  container + API status"
	@echo -e "    $(GREEN)make ava-rebuild$(RESET) rebuild Avalhla from Modelfile"
	@echo -e "    $(GREEN)make ava-log$(RESET)     tail container log"
	@echo ""
	@echo -e "  $(BOLD)CONTEXT$(RESET)"
	@echo -e "    $(GREEN)make ctx-8k$(RESET)      switch to 8192 context"
	@echo -e "    $(GREEN)make ctx-16k$(RESET)     switch to 16384 context (default)"
	@echo -e "    $(GREEN)make ctx-32k$(RESET)     switch to 32768 context (heavy)"
	@echo ""
	@echo -e "  $(BOLD)SYSTEM$(RESET)"
	@echo -e "    $(GREEN)make health$(RESET)      full read-only system report"
	@echo -e "    $(GREEN)make update$(RESET)      check for OS + flatpak updates"
	@echo -e "    $(GREEN)make gpu$(RESET)         NVIDIA status"
	@echo -e "    $(GREEN)make audio$(RESET)       PipeWire sinks/sources"
	@echo -e "    $(GREEN)make net$(RESET)         network status"
	@echo -e "    $(GREEN)make logs$(RESET)        recent errors"
	@echo ""
	@echo -e "  $(BOLD)DEV$(RESET)"
	@echo -e "    $(GREEN)make lab$(RESET)         enter coding-lab (Distrobox, dev tools only)"
	@echo -e "    $(GREEN)make tools$(RESET)       verify tool dependencies"
	@echo ""
	@echo -e "  $(BOLD)REPO$(RESET)"
	@echo -e "    $(GREEN)make review$(RESET)      lint repo for banned patterns"
	@echo -e "    $(GREEN)make status$(RESET)      git status, short"
	@echo -e "    $(GREEN)make push$(RESET)        commit + push (asks for message)"
	@echo -e "    $(GREEN)make pull$(RESET)        pull latest"
	@echo ""
	@echo -e "  $(BOLD)PRIVATE$(RESET)  $(DIM)local only, never pushed$(RESET)"
	@echo -e "    $(GREEN)make bible$(RESET)       open D42k.md"
	@echo -e "    $(GREEN)make keys$(RESET)        open Dawa.txt"
	@echo ""

.PHONY: verify fix ai
verify:
	@$(SCRIPTS)/verify-before-work.sh

fix:
	@$(SCRIPTS)/verify-before-work.sh --fix

ai:
	@echo "launching Avalhla..."
	@ollama run $(MODEL)

.PHONY: ava-start ava-stop ava-status ava-rebuild ava-log
ava-start:
	@echo "starting ollama.service..."
	@systemctl --user start ollama.service
	@for i in $$(seq 1 20); do \
		curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break; \
		sleep 1; \
	done
	@curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && echo "ready" || (echo "FAILED -- check systemctl --user status ollama.service"; exit 1)

ava-stop:
	@systemctl --user stop ollama.service && echo "stopped (VRAM freed)" || echo "nothing to stop"

ava-status:
	@echo "service:"
	@systemctl --user is-active ollama.service 2>/dev/null | sed 's/^/  /'
	@echo "API:"
	@curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && echo "  up" || echo "  down"
	@echo "loaded models:"
	@ollama ps 2>/dev/null | sed 's/^/  /' || true
	@echo "context (Quadlet):"
	@grep -oE 'OLLAMA_CONTEXT_LENGTH=[0-9]+' $$HOME/.config/containers/systemd/ollama.container 2>/dev/null | head -1 | sed 's/^/  /' || echo "  (not set)"

ava-rebuild:
	@if [ ! -f persona/avalhla.Modelfile ]; then echo "no persona/avalhla.Modelfile"; exit 1; fi
	@ollama create $(MODEL) -f persona/avalhla.Modelfile && echo "rebuilt $(MODEL)"

ava-log:
	@podman logs -f ollama 2>/dev/null || echo "container not running"

.PHONY: ctx-8k ctx-16k ctx-32k
ctx-8k:
	@$(SCRIPTS)/ollama-ctx 8192

ctx-16k:
	@$(SCRIPTS)/ollama-ctx 16384

ctx-32k:
	@$(SCRIPTS)/ollama-ctx 32768

.PHONY: health
health:
	@$(SCRIPTS)/verify-before-work.sh

.PHONY: update
update:
	@echo "OS updates:"
	@rpm-ostree upgrade --check 2>&1 | sed 's/^/  /'
	@echo ""
	@echo "Flatpak updates:"
	@flatpak remote-ls --updates 2>/dev/null | sed 's/^/  /' || echo "  (none)"

.PHONY: gpu
gpu:
	@nvidia-smi --query-gpu=name,driver_version,temperature.gpu,power.draw,memory.used,memory.total --format=csv,noheader 2>/dev/null | sed 's/^/  /' || echo "  nvidia-smi not available"

.PHONY: audio
audio:
	@echo "services:"
	@for s in pipewire pipewire-pulse wireplumber; do systemctl --user is-active --quiet $$s && echo "  OK  $$s" || echo "  XX  $$s"; done
	@echo "sinks:"
	@pactl list short sinks 2>/dev/null | sed 's/^/  /'

.PHONY: net
net:
	@ip -brief addr show | sed 's/^/  /'

.PHONY: logs
logs:
	@journalctl -p err --since "1 hour ago" --no-pager -q 2>/dev/null | tail -20 | sed 's/^/  /' || echo "  (no errors)"

.PHONY: lab
lab:
	@echo "entering coding-lab (type exit to leave)..."
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
	if [ -z "$$msg" ]; then echo "aborted -- no message"; exit 1; fi; \
	git add -A && git commit -m "$$msg" && git push && echo "pushed"

.PHONY: pull
pull:
	@git pull --rebase && echo "up to date"

.PHONY: bible
bible:
	@if [ -f private/D42k.md ]; then less private/D42k.md; else echo "private/D42k.md not found"; fi

.PHONY: keys
keys:
	@if [ -f private/Dawa.txt ]; then echo "opening credentials"; less private/Dawa.txt; else echo "private/Dawa.txt not found"; fi

.PHONY: journal-clean
journal-clean:
	@echo "cleaning journal (keep last 7 days)..."
	@sudo journalctl --rotate
	@sudo journalctl --vacuum-time=7d
	@echo "done"
