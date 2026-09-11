#!/usr/bin/env bash

# dynamic root as global dir
SHELL_ROOT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

init() {
    local cls=true
    local silent=false

    # parsing flags
    for arg in "$@"; do
        case "$arg" in
            --cls) cls=true ;;
            --no-cls) cls=false ;;
            --silent) silent=true ;;
        esac
    done

    [[ "$cls" == true ]] && clear

    # load modules
    shopt -s nullglob
    for module in "$SHELL_ROOT/modules"/*.sh; do
        source "$module"
    done
    shopt -u nullglob

    # autorun
    if [[ "$silent" == false ]]; then
	greet
    fi
}

init --no-cls

