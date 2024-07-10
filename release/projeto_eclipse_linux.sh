#!/bin/sh
echo -ne '\033c\033]0;Projeto Eclipse\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/projeto_eclipse_linux.x86_64" "$@"
