.PHONY: pdf pdf-demo clean

DEMO ?= 0
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER = UID=$(UID) GID=$(GID) docker compose run --rm -e UID=$(UID) -e GID=$(GID) latex
LATEXMK = latexmk -pdf -xelatex
DEMO_TEX = build/demo.tex

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
	$(DOCKER)
endif

pdf-demo:
	$(DOCKER) bash -lc "mkdir -p /app/build && rm -f /app/$(DEMO_TEX) /app/$(DEMO_TEX:.tex=.*) && printf '%s\n' '\def\demobib{1}\input{main.tex}' > /app/$(DEMO_TEX) && $(LATEXMK) /app/$(DEMO_TEX) && cp /app/$(DEMO_TEX:.tex=.pdf) /app/main.pdf && chown \$${UID:-1000}:\$${GID:-1000} /app/main.pdf"

clean:
	$(DOCKER) bash -lc "latexmk -C && rm -f /app/$(DEMO_TEX) /app/$(DEMO_TEX:.tex=.*)"
