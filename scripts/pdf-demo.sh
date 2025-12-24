#!/usr/bin/env bash
set -euo pipefail

base_dir="${BASE_DIR:-/app}"
demo_tex="${DEMO_TEX:?DEMO_TEX is required}"
if [[ ${demo_tex} = /* ]]; then
  demo_path="${demo_tex}"
else
  demo_path="${base_dir}/${demo_tex}"
fi
demo_dir="$(dirname "${demo_path}")"
main_pdf="${base_dir}/main.pdf"

mkdir -p "${demo_dir}"
latexmk -C "${demo_path}" >/dev/null 2>&1 || true
printf '%s\n' "\\def\\demobib{1}\\input{main.tex}" > "${demo_path}"
latexmk -pdf -xelatex "${demo_path}"
cp "${demo_path%.tex}.pdf" "${main_pdf}"
if [ "$(id -u)" -eq 0 ]; then
  chown "${UID:-1000}:${GID:-1000}" "${main_pdf}"
fi
