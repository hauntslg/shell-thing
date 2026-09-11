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
	printf "\e[33m%s\e[0m\n" "${greetings[$((RANDOM % ${#greetings[@]}))]}"
        return
    fi

    case "$action" in
        list)
            for g in "${greetings[@]}"; do
		printf "\e[33m%s\e[0m\n" "$g"
            done
            ;;
        *)
	    printf "\e[31mAction '%s' not found\e[0m\n" "$action"
            ;;
    esac
}
