NAVVI_DIR="$SHELL_ROOT/data/navvi"
NAVVI_FILE="$SHELL_ROOT/data/navvi/aliases"

mkdir -p "$NAVVI_DIR"
touch "$NAVVI_FILE"

nav() {
    navvi "$@"
}

path() {
    navvi path "$@"
}

navvi() {
    case "$1" in
	cd)
	    _navvi_cd "${@:2}"
	    ;;
	path)
	    _navvi_path "${@:2}"
	    ;;
	add)
	    _navvi_add "${@:2}"
	    ;;
	rm)
	    _navvi_remove "${@:2}"
	    ;;
	list)
	    _navvi_list
	    ;;
	"")
	    _navvi_list
	    ;;
	*)
	    _navvi_cd "$1"
	    ;;
    esac
}

# get a path from the navvi alias file based on the inputted alias
_navvi_path() {
    local input="$1"
    local alias="${input%%/*}"
    local suffix="${input#*/}"
    local path

    path="$(grep "^${alias}=" "$NAVVI_FILE" | cut -d= -f2-)"

    if [[ -z "$path" ]]; then
	return 1
    fi

    if [[ "$input" == */* ]]; then
	path="$path/$suffix"
    fi

    printf '%s\n' "$path"
}

# cd to an aliased path
_navvi_cd() {
    local path
    path="$(_navvi_path "$1")"

    if [[ -z "$path" ]]; then
	printf '\e[31mAlias not found: %s\e[0m\n' "$1"
	return 1
    fi

    cd -- "$path"
}

# add a new alias to the nav file
_navvi_add() {
    local alias="$1"
    local path="$2"

    # accept "here" as an alias for the current active dir
    if [[ "$path" == "here" ]]; then
	path="."
    fi

    if [[ -z "$alias" || -z "$path" ]]; then
	printf '\e[31mUsage: nav add <alias> <path>\e[0m\n'
	return 1
    fi

    if ! path="$(realpath -e "$path")"; then
    	printf '\e[31mPath does not exist: %s\e[0m\n' "$path"
	return 1
    fi

    # replace an alias if the one being added already exists
    if grep -q "^${alias}=" "$NAVVI_FILE"; then
	sed -i "s|^${alias}=.*|${alias}=${path}|" "$NAVVI_FILE"
    else # otherwise, just add the alias on a new line
	printf '%s=%s\n' "$alias" "$path" >> "$NAVVI_FILE"
    fi
}

_navvi_remove() {
    local alias="$1"

    if [[ -z "$alias" ]]; then
    	printf '\e[31mUsage: nav rm <alias>\e[0m\n'
	return 1
    fi

    if ! grep -q "^${alias}=" "$NAVVI_FILE"; then
    	printf '\e[31mAlias not found: %s\e[0m\n' "$alias"
	return 1
    fi

    sed -i "/^${alias}=/d" "$NAVVI_FILE"
}

_navvi_list() {
    # ..
    # hear me out
    cat "$NAVVI_FILE"
    # ts shi easyu lmao
}

