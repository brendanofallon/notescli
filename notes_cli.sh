# --- The Minimalist CLI Notes System ---

# 1. Define your root directory.
export NOTES_ROOT="$HOME/notes"

# Ensure the directory exists
mkdir -p "$NOTES_ROOT"

# 2. 'nn' (New Note): Quick entry for fleeting thoughts
nn() {
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="${NOTES_ROOT}/${timestamp}.md"
    
    if [ -z "$1" ]; then
        echo "❌ Error: No note content provided."
        return 1
    fi
    
    echo "# Note: ${timestamp}" > "$filename"
    echo "$1" >> "$filename"
    echo "✅ Note saved to: ${timestamp}.md"
}

# 3. 'na' (Note Access): Open/Create a note
na() {
    local target="${NOTES_ROOT}/$1"
    local editor="${EDITOR:-vim}"
    
    if [ -d "$target" ]; then
        # -G enables color on macOS ls
        cd "$target" && ls -FG
    elif [ -f "$target" ]; then
        $editor "$target"
    else
        mkdir -p "$(dirname "$target")"
        $editor "$target"
    fi
}

# 4. 'ns' (Note Search): Search with color
ns() {
    # --color=always preserves color when piping or in functions
    grep --color=always -ri "$1" "$NOTES_ROOT"
}

# 5. 'nl' (Note List): Tree view with forced color
nl() {
    echo "\n📓 Notes:\n"
    # -C forces color output even when piped to head
    tree -C -L 2 "$NOTES_ROOT" | head -n 50
}
