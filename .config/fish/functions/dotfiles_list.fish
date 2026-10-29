function dotfiles_list --argument-names file --description 'Print the names a dotfiles list file declares, one per line'
    # A list holds names separated by any whitespace; `#` starts a comment.
    if not test -f "$file"
        echo "dotfiles_list: no list $file" >&2
        return 1
    end
    string replace -r '#.*' '' <$file | string match -ra '\S+'
end
