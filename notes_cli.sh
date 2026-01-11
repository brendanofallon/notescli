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
    local name="$1"
    if [ -z "$name" ]; then
        name="$(date +"%Y-%m-%d_%H-%M-%S").md"
    fi
    
    local target="${NOTES_ROOT}/$name"
    local editor="${EDITOR:-vim}"
    
    if [ -n "$1" ] && [ -d "$target" ]; then
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
    local editor="${EDITOR:-vim}"
    local file_info
    
    # Use ripgrep to search and fzf to filter interactively
    file_info=$(
      rg --column --line-number --no-heading --color=always --smart-case "" "$NOTES_ROOT" | \
      fzf --ansi \
          --disabled \
          --query "$*" \
          --bind "change:reload:rg --column --line-number --no-heading --color=always --smart-case {q} \"$NOTES_ROOT\" || true" \
          --delimiter : \
          --preview 'bat --color=always --highlight-line {2} {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3'
    )
    
    if [[ -n "$file_info" ]]; then
        local file=$(echo "$file_info" | cut -d: -f1)
        local line=$(echo "$file_info" | cut -d: -f2)
        local col=$(echo "$file_info" | cut -d: -f3)
        
        # Open editor at the specific line and column if it's vim-like
        if [[ "$editor" =~ "vim" || "$editor" == "vi" || "$editor" == "nvim" ]]; then
            $editor "+call cursor($line, $col)" "$file"
        else
            $editor "$file"
        fi
    fi
}

# 5. 'nl' (Note List): Tree view with forced color
nl() {
    echo "\n📓 Notes:\n"
    # -C forces color output even when piped to head
    tree -C -L 2 "$NOTES_ROOT" | head -n 50
}
