#!/bin/bash

# ==============================================================================
# Script: install_dev_tools.sh
# Description: Installs user-specific development tooling (ASDF, NVM, ZSH plugins).
# Execution: Must be run as the standard user (NOT root).
# ==============================================================================

if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root. It is intended for the standard user." 
   exit 1
fi

echo "Installing Dev Tools for $USER..."

# ------------------------------------------------------------------------------
# Function: setup_zsh_addons
# Description: Installs Oh-My-Zsh and the Zsh Syntax Highlighting plugin.
# ------------------------------------------------------------------------------
setup_zsh_addons() {
    echo "Setting up Zsh enhancements..."
    # Install Oh-My-Zsh without dropping immediately into a zsh shell
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Clone the syntax highlighting plugin exactly where the .zshrc expects it
    if [ ! -d "$HOME/.config/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh-syntax-highlighting
    fi
}

# ------------------------------------------------------------------------------
# Function: setup_elixir_env
# Description: Installs ASDF and uses it to provision Erlang, Elixir, and Elixir-LS.
# ------------------------------------------------------------------------------
setup_elixir_env() {
    echo "Setting up ASDF and Elixir ecosystem..."
    if [ ! -d "$HOME/.asdf" ]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    fi
    # Source ASDF so it is available in this subshell
    source "$HOME/.asdf/asdf.sh"

    # Add required plugins (ignoring errors if they already exist)
    asdf plugin-add erlang || true
    asdf plugin-add elixir || true
    asdf plugin-add elixir-ls || true

    echo "Installing Erlang, Elixir, and Elixir-LS..."
    asdf install erlang latest || echo "Erlang install failed, maybe missing dependencies"
    asdf install elixir latest || echo "Elixir install failed"
    asdf install elixir-ls latest || echo "Elixir-ls install failed"

    # Set latest installed versions globally for the user
    asdf global erlang latest
    asdf global elixir latest
    asdf global elixir-ls latest
}

# ------------------------------------------------------------------------------
# Function: setup_node_env
# Description: Installs NVM (Node Version Manager) and the latest Node.js LTS.
# ------------------------------------------------------------------------------
setup_node_env() {
    echo "Setting up NVM and Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'

    # Install a bash language server for shell script IDE support
    npm i -g bash-language-server
}

# ------------------------------------------------------------------------------
# Function: install_ttt_editor
# Description: Installs the TTT terminal editor directly from its github script.
# ------------------------------------------------------------------------------
install_ttt_editor() {
    echo "Installing TTT Editor..."
    curl -sSfL https://raw.githubusercontent.com/eugenioenko/ttt/main/install.sh | sh
}

# ------------------------------------------------------------------------------
# Main Execution Block
# ------------------------------------------------------------------------------
setup_zsh_addons
setup_elixir_env
setup_node_env
install_ttt_editor

# Provide the user with Portainer startup instructions
echo "========================================"
echo "To start portainer, run the following command once docker is active:"
echo "docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest"
echo "========================================"
