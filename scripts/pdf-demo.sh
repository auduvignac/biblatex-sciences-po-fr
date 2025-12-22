#!/usr/bin/env bash
set -euo pipefail

demo_tex="build/demo.tex"

mkdir -p /app/build
rm -f "/app/${demo_tex}" "/app/${demo_tex%.tex}".*
printf '%s\n' "\\def\\demobib{1}\\input{main.tex}" > "/app/${demo_tex}"
latexmk -pdf -xelatex "/app/${demo_tex}"
cp "/app/${demo_tex%.tex}.pdf" /app/main.pdf
chown "${UID:-1000}:${GID:-1000}" /app/main.pdf
