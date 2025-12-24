.PHONY: pdf pdf-demo clean

DEMO ?= 0
USE_DOCKER ?= 0
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER = docker compose run --rm -e UID=$(UID) -e GID=$(GID) latex
DEMO_TEX = build/demo.tex

DEMO_SCRIPT = scripts/pdf-demo.sh
LATEXMK = latexmk -r latexmkrc -pdf -xelatex
LATEXMK_CLEAN = latexmk -r latexmkrc -C
TEXINPUTS = .:./style//:
BIBINPUTS = .:./bibliographies//:
BSTINPUTS = .:./style//:
LATEX_ENV = TEXINPUTS=$(TEXINPUTS) BIBINPUTS=$(BIBINPUTS) BSTINPUTS=$(BSTINPUTS)
export LATEXMK LATEXMK_CLEAN

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
ifeq ($(USE_DOCKER),1)
	$(DOCKER)
else
	$(LATEX_ENV) $(LATEXMK_CLEAN) main.tex
	$(LATEX_ENV) $(LATEXMK) main.tex
	cp build/main.pdf main.pdf
endif
endif

pdf-demo:
ifeq ($(USE_DOCKER),1)
	$(DOCKER) bash -lc "DEMO_TEX=\"$(DEMO_TEX)\" /app/$(DEMO_SCRIPT)"
else
	$(LATEX_ENV) BASE_DIR="$(CURDIR)" DEMO_TEX="$(DEMO_TEX)" ./$(DEMO_SCRIPT)
endif

clean:
ifeq ($(USE_DOCKER),1)
	$(DOCKER) bash -lc "$(LATEXMK_CLEAN) && rm -f /app/$(DEMO_TEX) /app/$(DEMO_TEX:.tex=).*"
else
	$(LATEX_ENV) $(LATEXMK_CLEAN)
	rm -f $(DEMO_TEX) $(DEMO_TEX:.tex=).*
	rm -f main.pdf
endif
