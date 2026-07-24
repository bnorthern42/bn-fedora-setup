#!/bin/bash

# ==============================================================================
# Script: install_desktop_and_apps.sh
# Description: Installs the desktop environment (KDE/Niri), graphical tools, 
#              and heavy system applications.
# Execution: Must be run with sudo.
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# ------------------------------------------------------------------------------
# Function: install_desktop_environments
# Description: Installs KDE Plasma as a fallback, and Niri as the primary Wayland WM.
# ------------------------------------------------------------------------------
install_desktop_environments() {
    echo "Installing desktop environments (KDE/Niri)..."
    dnf install -y @kde-desktop niri wayland-protocols-devel lightdm
}

# ------------------------------------------------------------------------------
# Function: install_utilities
# Description: Installs common graphical apps, terminals, and necessary build dependencies.
# ------------------------------------------------------------------------------
install_utilities() {
    echo "Installing desktop applications and build dependencies..."
    local apps=(
        "clang-tools-extra" "fd-find" "ripgrep" "alacritty" "ghostty" "docker" "docker-compose"
        "konsole" "rofi" "highlight" "arandr" "fontawesome-fonts" "fontawesome-fonts-web"
        "make" "autoconf" "ncurses-devel" "openssl-devel" "wxGTK-devel" # Erlang build dependencies
        "swaylock" "brightnessctl" "copr-cli" # Config dependencies (from Niri & Zsh aliases)
        "hyperv-daemons" # Hyper-V Guest integration userspace daemons
    )
    for app in "${apps[@]}"; do
        dnf install -y "$app"
    done
}

# ------------------------------------------------------------------------------
# Function: install_development_ides
# Description: Installs full Qt6 development stacks, KDevelop, and VSCodium.
# ------------------------------------------------------------------------------
install_development_ides() {
    echo "Installing full Qt6 dependencies and KDevelop..."
    # Installs the entire Qt6 development suite and KDevelop for C++ work
    dnf install -y qt6-*{devel,doc}* qt-creator kdevelop cmake extra-cmake-modules

    echo "Installing .NET SDKs..."
    # Attempts to install the latest .NET SDK, falling back if unavailable in Fedora repos yet
    dnf install -y dotnet-sdk-10.0 || dnf install -y dotnet-sdk-9.0 || dnf install -y dotnet-sdk-8.0

    echo "Installing VSCodium..."
    # Adds VSCodium repo key and repository config to DNF, then installs
    rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | tee /etc/yum.repos.d/vscodium.repo
    dnf install -y codium
}

# ------------------------------------------------------------------------------
# Function: install_flatpaks
# Description: Sets up Flathub and installs LibreWolf and GitFourchette.
# ------------------------------------------------------------------------------
install_flatpaks() {
    echo "Configuring Flatpak and installing Flatpak apps..."
    dnf install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub io.gitlab.librewolf-community org.gitfourchette.gitfourchette
}

# ------------------------------------------------------------------------------
# Function: configure_drivers_and_services
# Description: Installs Nvidia drivers, Pipewire for sound, and enables system services.
# ------------------------------------------------------------------------------
configure_drivers_and_services() {
    echo "Installing Nvidia proprietary drivers and Audio systems..."
    dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    dnf install -y pipewire pipewire-pulseaudio pipewire-alsa pipewire-jack

    echo "Enabling Docker, Desktop Display Manager, and Hyper-V services..."
    systemctl enable --now docker
    systemctl enable lightdm
    systemctl set-default graphical.target

    # Enable Hyper-V integration services
    systemctl enable --now hypervvssd hypervkvpd hypervfcopyd 2>/dev/null || true

    # Add the current human user to the docker group so they can run containers without sudo
    usermod -aG docker $SUDO_USER
}

# ------------------------------------------------------------------------------
# Main Execution Block
# ------------------------------------------------------------------------------
install_desktop_environments
install_utilities
install_development_ides
install_flatpaks
configure_drivers_and_services

echo "Note: Vicinae launcher requires manual installation via AppImage or source compilation from GitHub."
echo "Note: Keymapp requires manual installation (AppImage available on ZSA website)."
