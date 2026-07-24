# some more ls aliases
# exa is a rust application
alias ll="exa -lhga --color=always --group-directories-first --icons --octal-permissions --git --time-style=long-iso"
alias la='ls -A'
alias l='ls -CF'
alias llt='exa -lhg --color=always --group-directories-first --icons -T --git-ignore'

alias ls='ls -hN --color=auto --group-directories-first'

alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}
alias hyp="pushd ~/dotfiles/.config/hypr"
alias cls='clear'
#cat alternatives
alias bat='/usr/bin/bat'
alias ccat='highlight --out-format=ansi'

#see images in terminal (GPU accel. ones)
alias ic='kitty +kitten icat --align=left'

## cound files in dir - recurse
alias count='find . -type f | wc -l'
