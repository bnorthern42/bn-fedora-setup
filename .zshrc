# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# --- XDG SETTINGS ---
# This block is fine, defines where your config files should be stored.
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# --- ZSH & OH-MY-ZSH CONFIGURATION ---
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"
alias AppRun='apprun'
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    #git
    npm
    aliases
    colored-man-pages
    colorize
    sudo
    web-search
    copyfile
    copybuffer
    history
    jsontools
    frontend-search
    mvn
    perms
)

# --- LOAD OH MY ZSH FRAMEWORK ---
# This MUST come before your custom overrides.
source "$ZSH/oh-my-zsh.sh"


# --- YOUR CUSTOM SETTINGS (LOAD THESE LAST) ---

# Custom Environment Variables and Paths
export EDITOR='vim'
export BROWSER='google-chrome-stable'
export TEXMFCNF='~/.local/tex_config_dir:'
export PATH="$PATH:$HOME/.npm-packages/bin"
export NODE_PATH="$HOME/.npm-packages/lib/node_modules:$NODE_PATH"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
#pretty print for pagers like man pages etc
export PAGER="most"
# Sourcing your custom alias and function files
# Ensure these files exist at the specified path!
source "$XDG_CONFIG_HOME/.zsh_custom/.zsh_functions"
source "$XDG_CONFIG_HOME/.zsh_custom/.zsh_aliases"

# Your custom aliases
alias ff='fastfetch'
alias mc='macchina'
ZSH_COLORIZE_TOOL=chroma
# Startup command (runs after everything is loaded)


# -- START ACTIVESTATE INSTALLATION

# -- STOP ACTIVESTATE INSTALLATION
# -- START ACTIVESTATE DEFAULT RUNTIME ENVIRONMENT
export PATH="/home/$USER/.cache/activestate/bin:$PATH"
# -- STOP ACTIVESTATE DEFAULT RUNTIME ENVIRONMENT

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

cls
fastfetch
source /home/$USER/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH=$PATH:$HOME/go/bin

export LANG=en_US.UTF-8
unset LC_ALL
export LC_CTYPE=en_US.UTF-8

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT
