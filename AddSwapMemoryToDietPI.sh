#!/bin/bash
# Smart Swap Setup for DietPi
# Allows creating 4GB or 8GB swap file safely

# --- CONFIG ---
SWAP_FILE="/swapfile"
SWAP_SIZE_GB=""

# --- FUNCTIONS ---
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root (sudo)."
        exit 1
    fi
}

function ask_size() {
    echo "Select swap size:"
    echo "1) 4 GB"
    echo "2) 8 GB"
    read -rp "Enter choice [1 or 2]: " choice
    case "$choice" in
        1) SWAP_SIZE_GB=4 ;;
        2) SWAP_SIZE_GB=8 ;;
        *) echo "Invalid choice."; exit 1 ;;
    esac
}

function create_swap() {
    if [ -f "$SWAP_FILE" ]; then
        echo "Swap file already exists at $SWAP_FILE. Removing..."
        swapoff "$SWAP_FILE"
        rm -f "$SWAP_FILE"
    fi
    echo "Creating $SWAP_SIZE_GB GB swap file..."
    fallocate -l "${SWAP_SIZE_GB}G" "$SWAP_FILE" || \
    dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((SWAP_SIZE_GB*1024))
    
    chmod 600 "$SWAP_FILE"
    mkswap "$SWAP_FILE"
}

function enable_swap() {
    swapon "$SWAP_FILE"
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
}

function tune_swappiness() {
    read -rp "Set swappiness? (default 10 recommended) [y/n]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        read -rp "Enter swappiness value (1-100) [default 10]: " sw
        SW_VAL=${sw:-10}
        sysctl vm.swappiness=$SW_VAL
        grep -q "^vm.swappiness" /etc/sysctl.conf && \
        sed -i "s/^vm.swappiness=.*/vm.swappiness=$SW_VAL/" /etc/sysctl.conf || \
        echo "vm.swappiness=$SW_VAL" >> /etc/sysctl.conf
    fi
}

function show_status() {
    echo "Swap setup complete!"
    swapon --show
    free -h
}

# --- MAIN ---
check_root
ask_size
create_swap
enable_swap
tune_swappiness
show_status
