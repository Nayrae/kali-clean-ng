#!/usr/bin/env bash
# kali-clean-ng installer: i3 + alacritty + tmux + rofi + compton + zsh + nvim
# Run from a normal (non-root) user:  ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
NERD_FONTS_VERSION="v3.4.0"

info() { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

if [ "$EUID" -eq 0 ]; then
    echo "Run this as your normal user, not root (sudo is used where needed)." >&2
    exit 1
fi

# ---------------------------------------------------------------- packages
info "Updating system and installing packages"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    wget curl git unzip rsync thunar \
    i3 i3-wm i3blocks i3status rofi feh picom compton unclutter \
    alacritty kitty tmux zsh neovim lazygit xclip ripgrep fd-find zoxide \
    arandr flameshot arc-theme papirus-icon-theme lxappearance imagemagick \
    open-vm-tools-desktop sysstat pipx

# ---------------------------------------------------------------- i3blocks scripts
# i3blocks.conf uses /usr/share/i3blocks/<block>; the Debian package no longer ships them
info "Installing i3blocks-contrib scripts"
tmp="$(mktemp -d)"
git clone --depth 1 https://github.com/vivien/i3blocks-contrib "$tmp/contrib"
sudo mkdir -p /usr/share/i3blocks
for b in cpu_usage memory disk bandwidth; do
    sudo install -m 755 "$tmp/contrib/$b/$b" /usr/share/i3blocks/$b
done

# ---------------------------------------------------------------- fonts
info "Installing Nerd Fonts (Iosevka, RobotoMono)"
mkdir -p ~/.local/share/fonts
for f in Iosevka RobotoMono; do
    if fc-list | grep "$f Nerd Font" >/dev/null; then
        info "$f Nerd Font already installed, skipping"
        continue
    fi
    wget -q -O "$tmp/$f.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$f.zip"
    unzip -oq "$tmp/$f.zip" -d ~/.local/share/fonts/
done
fc-cache -f
rm -rf "$tmp"

# ---------------------------------------------------------------- shell / tools
if [ ! -d ~/.oh-my-zsh ]; then
    info "Installing oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d ~/.fzf ]; then
    info "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --key-bindings --completion --no-update-rc

if [ ! -d ~/.local/share/tmux/oh-my-tmux ]; then
    info "Installing oh-my-tmux"
    git clone --depth 1 https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
fi
mkdir -p ~/.config/tmux
ln -sfn ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf

info "Installing pywal"
pipx install pywal || warn "pywal install failed (optional)"

# ---------------------------------------------------------------- dotfiles
# Existing files are moved to $BACKUP before being replaced
deploy() {
    local src="$REPO/$1" dst="$HOME/$1"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "$1")"
        mv "$dst" "$BACKUP/$1"
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
}

info "Copying dotfiles (backups go to $BACKUP)"
for f in \
    .config/i3/config \
    .config/i3/i3blocks.conf \
    .config/i3/clipboard_fix.sh \
    .config/i3/cpu_graph.sh \
    .config/alacritty/alacritty.toml \
    .config/compton/compton.conf \
    .config/rofi/config.rasi \
    .config/rofi/tokyo.rasi \
    .config/tmux/tmux.conf.local \
    .config/flameshot/flameshot.ini \
    .config/nvim \
    .zshrc \
    .fehbg \
    .wallpaper; do
    deploy "$f"
done
chmod +x ~/.config/i3/clipboard_fix.sh ~/.config/i3/cpu_graph.sh ~/.fehbg

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    info "Setting zsh as default shell"
    sudo chsh -s "$(command -v zsh)" "$USER"
fi

echo
info "Done!"
echo "  - Reboot / log out and pick i3 on the login screen."
echo "  - Run lxappearance and select Arc-Dark (icons: Papirus)."
echo "  - Neovim plugins (LazyVim) install themselves on first 'nvim' launch."
echo "  - Optional: 'wal -i <image>' to generate a colour scheme; edit ~/.fehbg to change the wallpaper."
if [ -d "$BACKUP" ]; then echo "  - Your previous files were saved in $BACKUP"; fi
