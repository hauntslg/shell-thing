#!/usr/bin/env zsh

# dynamic root as global dir
export SHELL_ROOT="${0:A:h}"

init() {
    local cls=true
    local silent=true

    # parsing flags
    for arg in "$@"; do
        case "$arg" in
            --cls) cls=true ;;
            --no-cls) cls=false ;;
            --silent) silent=true ;;
            --not-silent) silent=false ;;
        esac
    done

    if [[ "$cls" == true ]]; then
        clear
    fi

    # load modules
    setopt local_options null_glob
    for module in "$SHELL_ROOT/modules"/*.zsh; do
        source "$module"
    done

    if [[ "$silent" == false ]]; then
        greet
    fi
}

init --no-cls --not-silent

