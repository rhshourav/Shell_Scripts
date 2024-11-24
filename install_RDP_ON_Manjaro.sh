#!/bin/bash

# Function to check and install yay
install_yay() {
    echo "Checking for yay..."
    if ! command -v yay &> /dev/null; then
        echo "yay not found. Installing yay..."
        sudo pacman -Sy --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed."
    fi
}

# Function to install and configure xRDP
configure_xrdp() {
    # Update system
    echo "Updating system..."
    sudo pacman -Syu --noconfirm

    # Install yay
    install_yay

    # Install xrdp and xorgxrdp-git from AUR
    echo "Installing xrdp and xorgxrdp-git..."
    yay -S --noconfirm xrdp xorgxrdp

    # Allow any user to start an X session
    echo "Configuring Xwrapper..."
    echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config

    # Check and configure session files
    echo "Configuring session for XFCE and KDE Plasma..."

    # XFCE and KDE configuration
    if [[ -f ~/.xinitrc ]]; then
        echo "Backing up existing .xinitrc..."
        mv ~/.xinitrc ~/.xinitrc.bak
    fi

    echo "Creating .xinitrc for XFCE and KDE Plasma support..."
    cat <<EOL > ~/.xinitrc
#!/bin/bash
# Session configuration for xRDP
SESSION=\${1:-plasma}

# Start the selected session
case "\$SESSION" in
    xfce)
        exec startxfce4
        ;;
    plasma)
        exec startplasma-x11
        ;;
    *)
        echo "Unknown session type: \$SESSION" >&2
        exit 1
        ;;
esac
EOL

    chmod +x ~/.xinitrc

    # Enable xRDP
    echo "Enabling xRDP service..."
    sudo systemctl enable --now xrdp.service

    echo "Configuration complete. Reboot your system to apply changes."
}

# Call the function
configure_xrdp
