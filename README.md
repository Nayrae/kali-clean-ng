# Kali-Clean-NG

Updated version of [kali-clean](https://github.com/xct/kali-clean): an i3 desktop for Kali with alacritty, tmux (oh-my-tmux), rofi (Tokyo Night), compton, zsh (oh-my-zsh + fzf + zoxide) and Neovim (LazyVim).

## Installation

Clone the repo and run the installer as your normal user (not root):

```
./install.sh
```

Any files it replaces are backed up to `~/.dotfiles-backup/<timestamp>/`.

When it finishes, reboot and pick **i3** on the login screen. Open a terminal (`super+Return`), run `lxappearance` and choose the Arc-Dark theme with Papirus icons.

## What's included

| Path | What it is |
|---|---|
| `.config/i3/` | i3 config, i3blocks bar (with CPU graph), VMware clipboard fix |
| `.config/alacritty/alacritty.toml` | Alacritty config (TOML format) |
| `.config/rofi/` | `config.rasi` + `tokyo.rasi` theme |
| `.config/compton/compton.conf` | Compositor (shadows, transparency) |
| `.config/tmux/tmux.conf.local` | oh-my-tmux local config with vi copy-mode |
| `.config/nvim/` | LazyVim starter config |
| `.config/flameshot/flameshot.ini` | Flameshot (`super+p`) |
| `.zshrc`, `.fehbg`, `.wallpaper/` | Shell config and wallpaper |

## Changes from kali-clean

- i3 now comes straight from apt, since gaps were merged into i3 4.22. Nothing is compiled anymore.
- Alacritty comes from apt and uses `alacritty.toml`. Alacritty 0.13 dropped the old `.yml` format.
- The rofi config uses the `.rasi` format.
- Nerd Fonts v3 are installed, and skipped if already present.
- Adds tmux, oh-my-tmux, Neovim with LazyVim, fzf, zoxide and lazygit.
- Installs pywal with pipx, because `pip3 install` is blocked on current Kali.
- Restores the i3blocks scripts that the Debian package no longer ships.

## Credits

Original setup by [xct](https://github.com/xct/kali-clean). Wallpaper by Wenqing Yan (https://www.yuumeiart.com/).
