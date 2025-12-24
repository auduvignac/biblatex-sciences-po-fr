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
latexmk_cmd="${LATEXMK:-latexmk -r latexmkrc -pdf -xelatex}"
latexmk_clean="${LATEXMK_CLEAN:-latexmk -r latexmkrc -C}"

mkdir -p "${demo_dir}"
read -r -a latexmk_clean_argv <<< "${latexmk_clean}"
read -r -a latexmk_cmd_argv <<< "${latexmk_cmd}"
env ${LATEX_ENV:-} "${latexmk_clean_argv[@]}" "${demo_path}" >/dev/null 2>&1 || true
printf '%s\n' "\\def\\demobib{1}\\input{main.tex}" > "${demo_path}"
env ${LATEX_ENV:-} "${latexmk_cmd_argv[@]}" "${demo_path}"
cp "${demo_path%.tex}.pdf" "${main_pdf}"
if [ "$(id -u)" -eq 0 ]; then
  chown "${UID:-1000}:${GID:-1000}" "${main_pdf}"
fi
