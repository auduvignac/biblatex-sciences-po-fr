.PHONY: pdf pdf-demo clean

DEMO ?= 0
USE_DOCKER ?= 0
STYLE_DIR ?= ./style
BIB_DIR ?= ./bibliographies
UID ?= $(shell sh -c 'id -u 2>/dev/null || echo 1000')
GID ?= $(shell sh -c 'id -g 2>/dev/null || echo 1000')

DOCKER = docker compose run --rm -e UID=$(UID) -e GID=$(GID) -e DEMO_TEX -e LATEXMK -e LATEXMK_CLEAN -e STYLE_DIR -e BIB_DIR -e TEXINPUTS -e BIBINPUTS -e BSTINPUTS latex
DEMO_TEX = build/demo.tex
export DEMO_TEX

DEMO_SCRIPT = scripts/pdf-demo.sh
LATEXMK = latexmk -r latexmkrc -pdf -xelatex
LATEXMK_CLEAN = latexmk -r latexmkrc -C
TEXINPUTS := .:$(STYLE_DIR)//$(if $(TEXINPUTS),:$(TEXINPUTS),:)
BIBINPUTS := .:$(BIB_DIR)//$(if $(BIBINPUTS),:$(BIBINPUTS),:)
BSTINPUTS := .:$(STYLE_DIR)//$(if $(BSTINPUTS),:$(BSTINPUTS),:)
LATEX_ENV = TEXINPUTS=$(TEXINPUTS) BIBINPUTS=$(BIBINPUTS) BSTINPUTS=$(BSTINPUTS)
export LATEXMK LATEXMK_CLEAN
define prepare_main_pdf_mount
	@if [ -d main.pdf ]; then \
		rm -rf main.pdf; \
	else \
		rm -f -- main.pdf; \
	fi
	@touch main.pdf
endef

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
ifeq ($(USE_DOCKER),1)
	$(prepare_main_pdf_mount)
	$(DOCKER)
else
	$(LATEX_ENV) $(LATEXMK_CLEAN) main.tex
	$(LATEX_ENV) $(LATEXMK) main.tex
	@if [ -d main.pdf ]; then rm -rf main.pdf; fi
	cp build/main.pdf main.pdf
endif
endif

pdf-demo:
ifeq ($(USE_DOCKER),1)
	$(prepare_main_pdf_mount)
	$(DOCKER) bash -lc "/app/$(DEMO_SCRIPT)"
else
	$(LATEX_ENV) BASE_DIR="$(CURDIR)" DEMO_TEX="$(DEMO_TEX)" ./$(DEMO_SCRIPT)
endif

clean:
ifeq ($(USE_DOCKER),1)
	$(DOCKER) bash -lc "$$LATEXMK_CLEAN && rm -f /app/$$DEMO_TEX /app/$${DEMO_TEX%.tex}.*"
else
	$(LATEX_ENV) $(LATEXMK_CLEAN)
	rm -f $(DEMO_TEX) $(basename $(DEMO_TEX)).*
	rm -f main.pdf
endif
