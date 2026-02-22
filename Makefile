.PHONY: pdf pdf-demo clean

# Build toggles
DEMO ?= 0
USE_DOCKER ?= 0

# Project layout (override-friendly for subtree/integration use)
STYLE_DIR ?= ./style
BIB_DIR ?= ./bibliographies

# Windows-friendly UID/GID detection (keeps Unix behavior intact)
ifeq ($(OS),Windows_NT)
UID ?= 1000
GID ?= 1000
else
UID ?= $(shell id -u 2>/dev/null || echo 1000)
GID ?= $(shell id -g 2>/dev/null || echo 1000)
endif

# Shared tool commands (used by both local and Docker builds)
DEMO_SCRIPT = scripts/pdf-demo.sh
DEMO_TEX = build/demo.tex
LATEXMK ?= latexmk -r latexmkrc -pdf -xelatex
LATEXMK_CLEAN ?= latexmk -r latexmkrc -C

# TeX/Biber lookup paths (apply in both modes)
TEXINPUTS := .:$(STYLE_DIR)//$(if $(TEXINPUTS),:$(TEXINPUTS),:)
BIBINPUTS := .:$(BIB_DIR)//$(if $(BIBINPUTS),:$(BIBINPUTS),:)
BSTINPUTS := .:$(STYLE_DIR)//$(if $(BSTINPUTS),:$(BSTINPUTS),:)
LATEX_ENV = TEXINPUTS=$(TEXINPUTS) BIBINPUTS=$(BIBINPUTS) BSTINPUTS=$(BSTINPUTS)

# Docker command: pass through build variables and input paths.
DOCKER = docker compose run --rm -e UID=$(UID) -e GID=$(GID) -e DEMO_TEX -e LATEXMK -e LATEXMK_CLEAN -e STYLE_DIR -e BIB_DIR -e TEXINPUTS -e BIBINPUTS -e BSTINPUTS latex

# Files matched in .gitignore that should be purged by clean.
CLEAN_IGNORED = find . -type f \( \
	-name '*.aux' -o \
	-name '*.bbl' -o \
	-name '*.bcf' -o \
	-name '*.blg' -o \
	-name '*.fdb_latexmk' -o \
	-name '*.fls' -o \
	-name '*.lof' -o \
	-name '*.log' -o \
	-name '*.lot' -o \
	-name '*.out' -o \
	-name '*.run.xml' -o \
	-name '*.synctex.gz' -o \
	-name '*.toc' -o \
	-name '*.xdv' \
\) -delete
export DEMO_TEX LATEXMK LATEXMK_CLEAN

define prepare_main_pdf_mount
	@if [ -d main.pdf ]; then \
		rm -rf main.pdf; \
	else \
		rm -f -- main.pdf; \
	fi
	@touch main.pdf
endef

# Keep target recipes compact by resolving per-mode runners once.
ifeq ($(USE_DOCKER),1)
PREPARE_PDF = $(prepare_main_pdf_mount)
RUN_PDF = $(DOCKER)
RUN_DEMO = $(DOCKER) bash -lc "/app/$(DEMO_SCRIPT)"
RUN_CLEAN = $(DOCKER) bash -lc "cd /app && eval \"$$LATEXMK_CLEAN\" && $(CLEAN_IGNORED) && rm -f /app/$$DEMO_TEX /app/$${DEMO_TEX%.tex}.*"
else
PREPARE_PDF = @true
RUN_PDF = $(LATEX_ENV) bash -lc "eval \"$$LATEXMK_CLEAN main.tex\" && eval \"$$LATEXMK main.tex\" && cp build/main.pdf main.pdf"
RUN_DEMO = $(LATEX_ENV) BASE_DIR="$(CURDIR)" DEMO_TEX="$(DEMO_TEX)" ./$(DEMO_SCRIPT)
RUN_CLEAN = $(LATEX_ENV) bash -lc "eval \"$$LATEXMK_CLEAN\" && $(CLEAN_IGNORED) && rm -f \"$$DEMO_TEX\" \"$${DEMO_TEX%.tex}.*\" main.pdf"
endif

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
	$(PREPARE_PDF)
	$(RUN_PDF)
endif

pdf-demo:
	$(PREPARE_PDF)
	$(RUN_DEMO)

clean:
	$(RUN_CLEAN)
