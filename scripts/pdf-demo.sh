#!/usr/bin/env bash
set -euo pipefail

demo_tex="${DEMO_TEX:?DEMO_TEX is required}"

mkdir -p /app/build
latexmk -C "/app/${demo_tex}" >/dev/null 2>&1 || true
printf '%s\n' "\\def\\demobib{1}\\input{main.tex}" > "/app/${demo_tex}"
latexmk -pdf -xelatex "/app/${demo_tex}"
cp "/app/${demo_tex%.tex}.pdf" /app/main.pdf
if [ "$(id -u)" -eq 0 ]; then
  chown "${UID:-1000}:${GID:-1000}" /app/main.pdf
fi
