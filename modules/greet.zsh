greet() {
    greetings=(
        "here we are."
        "welcome back."
        "hello again."
        "something new?"
        "don't break anything. again."
        "what is it this time?"
        "back so soon?"
    )

    local action="$1"

    if [[ -z "$action" ]]; then
        print -P "%F{yellow}${greetings[$((RANDOM % ${#greetings[@]} + 1))]}%f"
            return
    fi

    case "$action" in
        list)
            for g in "${greetings[@]}"; do
                print -P "%F{yellow}$g%f"
            done
            ;;
        *)
            print -P "%F{red}Action '$action' not found%f"
            ;;
    esac
}
