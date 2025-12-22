.PHONY: pdf pdf-demo clean

DEMO ?= 0
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER = docker compose run --rm -e UID=$(UID) -e GID=$(GID) latex
DEMO_TEX = build/demo.tex

DEMO_SCRIPT = scripts/pdf-demo.sh

pdf:
ifeq ($(DEMO),1)
	$(MAKE) pdf-demo
else
	$(DOCKER)
endif

pdf-demo:
	$(DOCKER) bash -lc "chmod +x /app/$(DEMO_SCRIPT) && DEMO_TEX=$(DEMO_TEX) /app/$(DEMO_SCRIPT)"

clean:
	$(DOCKER) bash -lc "latexmk -C && rm -f /app/$(DEMO_TEX) /app/$(DEMO_TEX:.tex=.*)"
