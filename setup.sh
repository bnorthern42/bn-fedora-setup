#!/bin/bash

# ==============================================================================
# Script: setup.sh
# Description: Main orchestrator for setting up a Fedora Server as a daily driver.
#              Configures the system, installs base packages, sets up ZSH, 
#              moves user config files, and calls the secondary setup scripts.
# Execution: Must be run with sudo.
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# ------------------------------------------------------------------------------
# Function: optimize_dnf
# Description: Speeds up DNF by enabling parallel downloads, fastest mirrors, 
#              and caching optimizations.
# ------------------------------------------------------------------------------
optimize_dnf() {
    echo "Optimizing DNF package manager..."
    echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
    echo "fastestmirror=True" >> /etc/dnf/dnf.conf
    echo "defaultyes=True" >> /etc/dnf/dnf.conf
    echo "keepcache=True" >> /etc/dnf/dnf.conf
    echo "metadata_expire=1h" >> /etc/dnf/dnf.conf
}

# ------------------------------------------------------------------------------
# Function: setup_repositories
# Description: Enables necessary third-party repositories like Copr and RPM Fusion.
# ------------------------------------------------------------------------------
setup_repositories() {
    echo "Configuring repositories..."
    dnf install -y dnf-plugins-core
    # Enable Copr repository for Ghostty terminal
    dnf copr enable -y scottames/ghostty
    # Enable RPM Fusion for proprietary Nvidia drivers and multimedia codecs
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    dnf update -y
}

# ------------------------------------------------------------------------------
# Function: install_base_tools
# Description: Installs standard CLI tools and system utilities.
# ------------------------------------------------------------------------------
install_base_tools() {
    echo "Installing base CLI tools..."
    local initpackages=(
        "gcc" "gcc-c++" "git" "curl" "wget" "vim" "emacs" "eza" "zsh" "neofetch" 
        "ansiweather" "pwgen" "gdb"
    )

    for p in "${initpackages[@]}"; do
        dnf install -y "$p"
    done
}

# ------------------------------------------------------------------------------
# Function: configure_zsh_and_configs
# Description: Sets Zsh as the default shell and moves dotfiles into ~/.config
# ------------------------------------------------------------------------------
configure_zsh_and_configs() {
    echo "Configuring Zsh and migrating configuration directories..."
    # Change shell for both root and the standard user
    chsh -s $(which zsh)
    sudo -u $SUDO_USER chsh -s $(which zsh)

    # Copy the customized .zshrc from the repo to the user's home directory
    local conf="/home/$SUDO_USER/.zshrc"
    rm -f "$conf"
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
    cp "$SCRIPT_DIR/.zshrc" "$conf"
    chown $SUDO_USER:$SUDO_USER "$conf"

    # Migrate all specified application config folders into ~/.config
    local CONFIG_DIR="/home/$SUDO_USER/.config"
    mkdir -p "$CONFIG_DIR"

    echo "Copying config directories to $CONFIG_DIR..."
    cp -r "$SCRIPT_DIR/alacritty" "$CONFIG_DIR/"
    
    # Emacs config should be placed in ~/.emacs.d
    cp -r "$SCRIPT_DIR/emacsCppHero" "/home/$SUDO_USER/.emacs.d"
    
    cp -r "$SCRIPT_DIR/ghostty" "$CONFIG_DIR/"
    cp -r "$SCRIPT_DIR/niri" "$CONFIG_DIR/"
    cp -r "$SCRIPT_DIR/noctalia" "$CONFIG_DIR/"
    cp -r "$SCRIPT_DIR/vicinae" "$CONFIG_DIR/"
    cp -r "$SCRIPT_DIR/zsh_custom_public" "$CONFIG_DIR/.zsh_custom"

    # Ensure the standard user owns their configuration files
    chown -R $SUDO_USER:$SUDO_USER "$CONFIG_DIR"
    chown -R $SUDO_USER:$SUDO_USER "/home/$SUDO_USER/.emacs.d"
}

# ------------------------------------------------------------------------------
# Main Execution Block
# ------------------------------------------------------------------------------
echo "Starting Fedora Setup..."
optimize_dnf
setup_repositories
install_base_tools
configure_zsh_and_configs

echo "Delegating to application and development tool scripts..."
chmod +x install_desktop_and_apps.sh install_dev_tools.sh

# Run desktop apps installation as root
./install_desktop_and_apps.sh

# Run dev tools installation as the standard user
sudo -u $SUDO_USER ./install_dev_tools.sh

echo "Setup complete. Please reboot your machine."
