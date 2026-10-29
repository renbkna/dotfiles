function dots --wraps git --description "git for the dotfiles bare repo (~/.dotfiles, work tree ~)"
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end
