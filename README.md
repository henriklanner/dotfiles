# dotfiles

One repo for both Windows and WSL, managed with [chezmoi](https://chezmoi.io).
Each machine (Windows host, each WSL distro) has its own clone and applies only what's relevant to it.

| Path in repo | Lands at | Applies on |
|---|---|---|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | both (templated per OS) |
| `dot_config/git/ignore` | `~/.config/git/ignore` | both |
| `dot_config/starship.toml` | `~/.config/starship.toml` | both |
| `dot_zshrc` | `~/.zshrc` | WSL |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` | WSL |
| `dot_wslconfig` | `%USERPROFILE%\.wslconfig` | Windows |
| `Documents/PowerShell/...profile.ps1` | `$PROFILE` | Windows |
| `.chezmoiscripts/windows/*` | winget installs | Windows |
| `.chezmoiscripts/linux/*` | apt + installers | WSL |

OS filtering lives in `.chezmoiignore`; per-machine answers (name, email) are prompted once by `.chezmoi.toml.tmpl`.

## Bootstrap

**Windows (PowerShell):**

```powershell
winget install twpayne.chezmoi
chezmoi init --apply henriklanner
wsl --install -d Ubuntu   # latest LTS; admin, reboot
```

**WSL (Ubuntu):**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply henriklanner
```

## Daily use

```bash
chezmoi edit ~/.zshrc     # edit the source, not the target
chezmoi diff              # preview
chezmoi apply             # apply
chezmoi cd                # jump into the repo to commit/push
chezmoi update            # pull + apply on another machine
```
