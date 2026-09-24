# Makefile — cheatsheets

ritual:
	@cat RITUAL.txt

board:
	~/Avalhla/scripts/commands-board.sh
	@echo "Open with: less ~/COMMANDS_BOARD.txt"

bin:
	@mkdir -p bin
	@for f in scripts/*; do \
		[ -x "$$f" ] || continue; \
		n="$$(basename "$$f")"; \
		[ -e "bin/$$n" ] && continue; \
		ln -s "../$$f" "bin/$$n" && echo "+ bin/$$n"; \
	done
.PHONY: bin
