#!/usr/bin/env bash
set -euo pipefail

# Simple dependency installer for my Hyprland setup.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_AUR=true
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)-$$"
CONFIG_DIRS=(hypr quickshell waybar kitty dunst)

for arg in "$@"; do
    case "$arg" in
        --no-aur)
            INSTALL_AUR=false
            ;;
        --help|-h)
            echo "Usage: ./install_sai.sh [--no-aur]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: ./install_sai.sh [--no-aur]" >&2
            exit 1
            ;;
    esac
done

if [[ $EUID -eq 0 ]]; then
    echo "Run this as your normal user, not root."
    exit 1
fi

if ! command -v pacman >/dev/null; then
    echo "pacman was not found. This script is meant for Arch Linux."
    exit 1
fi

if ! command -v sudo >/dev/null; then
    echo "sudo is required."
    exit 1
fi

package_list() {
    grep -vE '^\s*(#|$)' "$1"
}

copy_configs() {
    mkdir -p "$CONFIG_HOME"

    for name in "${CONFIG_DIRS[@]}"; do
        local source_dir="$SCRIPT_DIR/config/$name"
        local target_dir="$CONFIG_HOME/$name"

        if [[ ! -d "$source_dir" ]]; then
            continue
        fi

        if [[ -e "$target_dir" ]]; then
            mkdir -p "$BACKUP_DIR"
            echo "Backing up $target_dir to $BACKUP_DIR/$name"
            cp -a "$target_dir" "$BACKUP_DIR/$name"
        else
            mkdir -p "$target_dir"
        fi

        echo "Copying $name config..."
        cp -a "$source_dir/." "$target_dir/"
    done

    find "$CONFIG_HOME/hypr" "$CONFIG_HOME/quickshell" "$CONFIG_HOME/waybar" \
        -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2>/dev/null || true

    if [[ -d "$BACKUP_DIR" ]]; then
        echo "Old configs were backed up to $BACKUP_DIR"
    fi
}

echo "Checking sudo access..."
sudo -v

echo "Installing base tools..."
sudo pacman -S --needed --noconfirm base-devel git

if $INSTALL_AUR; then
    if command -v yay >/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null; then
        AUR_HELPER="paru"
    else
        echo "Installing yay for AUR packages..."
        tmp_dir="$(mktemp -d)"
        git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
        (cd "$tmp_dir/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp_dir"
        AUR_HELPER="yay"
    fi
fi

PACMAN_PACKAGES="$SCRIPT_DIR/packages/pacman.txt"
AUR_PACKAGES="$SCRIPT_DIR/packages/aur.txt"

if [[ -f "$PACMAN_PACKAGES" ]]; then
    mapfile -t packages < <(package_list "$PACMAN_PACKAGES")
    echo "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
else
    echo "Missing package list: $PACMAN_PACKAGES"
    exit 1
fi

if $INSTALL_AUR && [[ -f "$AUR_PACKAGES" ]]; then
    mapfile -t aur_packages < <(package_list "$AUR_PACKAGES")
    echo "Installing AUR packages..."
    "$AUR_HELPER" -S --needed --noconfirm "${aur_packages[@]}"
elif ! $INSTALL_AUR; then
    echo "Skipping AUR packages."
fi

copy_configs

echo "Done."
