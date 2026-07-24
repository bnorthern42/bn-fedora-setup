# Fedora Setup for Daily Driver

This repository contains configuration and installation scripts to provision a complete development environment on Fedora Server (specifically intended for Hyper-V) tailored for Elixir, C/C++, and C# development.

## Prerequisites
- A fresh installation of **Fedora Server Edition**.
- Ensure your network is active and connected to the internet.
- You must have `sudo` privileges.

## How to Use

1. **Clone the Repository**
   First, pull down these configurations onto your Fedora machine:
   ```bash
   git clone <your-repository-url> bn-fedora-setup
   cd bn-fedora-setup
   ```

2. **Make the Scripts Executable**
   Ensure the three main setup scripts are executable:
   ```bash
   chmod +x setup.sh install_desktop_and_apps.sh install_dev_tools.sh
   ```

3. **Run the Main Setup Script**
   The entire installation process is orchestrated by `setup.sh`. Run it using `sudo`. 
   > **Note:** Do *not* run the other two scripts directly; `setup.sh` automatically calls them with the correct permissions (Root vs User context).
   
   ```bash
   sudo ./setup.sh
   ```

   **What this does:**
   - Optimizes DNF package downloads and installs fundamental CLI tools.
   - Bootstraps ZSH and moves all configuration files (Niri, Alacritty, Ghostty, Emacs, etc.) to your `~/.config` folder.
   - Seamlessly calls `install_desktop_and_apps.sh` (as root) to handle heavy applications like Docker, KDE, VSCodium, Qt6 tooling, KDevelop, Nvidia drivers, and Flatpaks (LibreWolf & GitFourchette).
   - Seamlessly calls `install_dev_tools.sh` (as your normal user) to configure ASDF (Erlang/Elixir), NVM (Node.js), and Oh-My-Zsh addons.

4. **Manual Installation Notes**
   After the script finishes, you will need to manually download the AppImage or compile the source for the following graphical tools:
   - **Vicinae** (Native desktop launcher)
   - **Keymapp** (ZSA keyboard application)

5. **Reboot**
   Once the script finishes, it is highly recommended to reboot the machine so the kernel modules (like Nvidia), groups (like Docker), and the desktop manager (LightDM) properly initialize.
   ```bash
   sudo reboot
   ```

6. **Post-Installation (Portainer)**
   When you boot into the desktop environment, you can deploy Portainer for Docker management using the command output by the setup script:
   ```bash
   docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
   ```
