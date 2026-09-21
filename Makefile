# Makefile — Imagination-V0.1 (lore only)

.PHONY: help count index dream canon clean

help:
	@echo "Imagination-V0.1 — lore commands"
	@echo ""
	@echo "  make count   — count files and words"
	@echo "  make index   — list all lore files"
	@echo "  make canon   — show Canon.md"
	@echo "  make dream   — show DREAM.md"
	@echo "  make help    — this message"

count:
	@echo "Files:"
	@find . -type f -not -path './.git/*' | wc -l
	@echo "Words:"
	@find . -type f -not -path './.git/*' -name '*.md' -exec cat {} + | wc -w

index:
	@find . -type f -not -path './.git/*' | sort

canon:
	@cat Canon.md

dream:
	@cat imagination/DREAM.md

clean:
	@echo "Nothing to clean — this is a lore branch."
