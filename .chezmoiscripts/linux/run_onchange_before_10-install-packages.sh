#!/usr/bin/env bash
# Installs WSL/Ubuntu tools. Re-runs automatically whenever this file changes.
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
    zsh git curl wget unzip build-essential ca-certificates \
    ripgrep fd-find fzf bat jq tmux zoxide eza git-delta \
    zsh-autosuggestions zsh-syntax-highlighting \
    libicu-dev  # ICU for .NET; -dev keeps the package name stable across Ubuntu releases

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

# Docker Engine (official apt repo) instead of Docker Desktop on Windows
if ! command -v docker >/dev/null; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
getent group docker | grep -qw "$USER" || sudo usermod -aG docker "$USER"

# Docker's service needs systemd; recent WSL Ubuntu images enable it, older ones don't
if ! grep -qs '^systemd=true' /etc/wsl.conf; then
    printf '\n[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf >/dev/null
    echo ">>> Enabled systemd in /etc/wsl.conf. Run 'wsl --shutdown' from Windows, then reopen Ubuntu."
fi
if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    sudo systemctl enable --now docker
fi

# Tools not in apt (or too old there) go to ~/.local/bin
command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
command -v mise     >/dev/null || curl -fsSL https://mise.run | sh
if ! command -v lazygit >/dev/null; then
    v=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | sed 's/^v//')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_x86_64.tar.gz" \
        | tar -xz -C "$HOME/.local/bin" lazygit
fi
if ! command -v lazydocker >/dev/null; then
    v=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | jq -r .tag_name | sed 's/^v//')
    curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${v}/lazydocker_${v}_Linux_x86_64.tar.gz" \
        | tar -xz -C "$HOME/.local/bin" lazydocker
fi

# .NET SDK via dotnetup (user-level, no sudo). PATH and DOTNET_ROOT are set in .zshrc,
# so dotnetup's own profile editing (`dotnetup env set shell`) is deliberately not used.
[ -x "$HOME/.dotnetup/dotnetup" ] || curl -fsSL https://aka.ms/dotnetup/get-dotnetup.sh | bash
"$HOME/.dotnetup/dotnetup" install lts --interactive false --no-progress

# zsh as login shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(command -v zsh)"
fi
