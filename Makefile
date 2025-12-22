.PHONY: pdf clean

DEMO ?= 0
UID := $(shell id -u)
GID := $(shell id -g)

DOCKER = UID=$(UID) GID=$(GID) docker compose run --rm -e UID=$(UID) -e GID=$(GID) latex
LATEXMK = latexmk -pdf -xelatex
DEMO_TEX = demo.tex

pdf:
ifeq ($(DEMO),1)
	$(DOCKER) bash -lc "mkdir -p /app/build && rm -f /app/$(DEMO_TEX) /app/build/$(DEMO_TEX:.tex=.*) && printf '\\\\def\\\\demobib{1}\\\\input{main.tex}\\n' > /app/$(DEMO_TEX) && $(LATEXMK) $(DEMO_TEX) && cp /app/build/$(DEMO_TEX:.tex=.pdf) /app/main.pdf && chown \$${UID:-1000}:\$${GID:-1000} /app/main.pdf"
else
	$(DOCKER)
endif

clean:
	$(DOCKER) bash -lc "latexmk -C && rm -f /app/$(DEMO_TEX) /app/build/$(DEMO_TEX:.tex=.*)"
