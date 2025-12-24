.PHONY: pdf pdf-demo clean

DEMO ?= 0
USE_DOCKER ?= 0
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER = docker compose run --rm -e UID=$(UID) -e GID=$(GID) -e DEMO_TEX -e LATEXMK -e LATEXMK_CLEAN latex
DEMO_TEX = build/demo.tex
export DEMO_TEX

DEMO_SCRIPT = scripts/pdf-demo.sh
LATEXMK = latexmk -r latexmkrc -pdf -xelatex
LATEXMK_CLEAN = latexmk -r latexmkrc -C
TEXINPUTS := .:./style//:$(TEXINPUTS)
BIBINPUTS := .:./bibliographies//:$(BIBINPUTS)
BSTINPUTS := .:./style//:$(BSTINPUTS)
LATEX_ENV = TEXINPUTS=$(TEXINPUTS) BIBINPUTS=$(BIBINPUTS) BSTINPUTS=$(BSTINPUTS)
export LATEXMK LATEXMK_CLEAN

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
ifeq ($(USE_DOCKER),1)
	rm -f -- main.pdf
	@touch main.pdf
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
	rm -f -- main.pdf
	@touch main.pdf
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
