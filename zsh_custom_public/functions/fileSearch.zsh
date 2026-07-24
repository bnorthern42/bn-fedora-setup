
# rgf - Recursive Git Function Search
#
# This function searches for a string within a git repository and displays the
# matching lines along with their surrounding code context (either the full
# function or a fixed number of lines) using 'bat' for syntax highlighting.
#
# Usage: rgf <search_term> [-c|--context]
#   -c, --context: Display 10 lines of context instead of the full function.
rgf() {
    local search_term=""
    local context_arg="-W" # Default to function context

    # 1. Parse arguments (Flag for 10 lines context vs Function context)
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -c|--context) context_arg="-C 10" ;; # Switch to 10 lines
            *) search_term="$1" ;;
        esac
        shift
    done

    if [[ -z "$search_term" ]]; then
        echo "Usage: ggbat <search_string> [-c|--context]"
        return 1
    fi

    # 2. Find files containing the term
    # We use 'while read' to handle file names with spaces correctly
    git grep -l "$search_term" | while read -r file; do

        # 3. The Magic Line
        # -h: Suppresses the "filename:" prefix (removes first column)
        # -W: Shows the whole function
        # -- "$file": Ensures we only grep the current file in the loop

        git grep -h $context_arg --color=never "$search_term" -- "$file" | \
        #local LN=$(grep -n "$search_term" "$file")
        # 4. Pipe to bat
        # --file-name: Tells bat which language to highlight and prints a nice header
        # --style=grid,numbers: Makes it look like a code block
        bat --color=always --file-name "$file" --style=header,grid,numbers --theme=Dracula # | less +$LN
    done

}

# rg2: Search for two patterns on the same line using PCRE2 lookaheads.
# Usage: rg2 <pattern1> <pattern2> [path]
# Example: rg2 "error" "timeout" ./src
rg2() {
    # If a path is provided as a 3rd argument, use it; otherwise, search current directory.
    local path="${3:-.}"
    /usr/bin/rg -P "(?=.*$1)(?=.*$2)" "$path"
}
