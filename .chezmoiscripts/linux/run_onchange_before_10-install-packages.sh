#!/usr/bin/env bash
# Installs WSL/Ubuntu tools. Re-runs automatically whenever this file changes.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
    zsh git curl wget unzip build-essential ca-certificates \
    ripgrep fd-find fzf bat jq tmux zoxide eza git-delta

# Ubuntu ships fd and bat under different names
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# GitHub CLI (official apt repo)
if ! command -v gh >/dev/null; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update && sudo apt-get install -y gh
fi

# Tools not in apt (or too old there) go to ~/.local/bin
command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
command -v mise     >/dev/null || curl -fsSL https://mise.run | sh
if ! command -v lazygit >/dev/null; then
    v=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | sed 's/^v//')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_x86_64.tar.gz" \
        | tar -xz -C "$HOME/.local/bin" lazygit
fi

# zsh as login shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(command -v zsh)"
fi
