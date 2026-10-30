# dotfiles

My dev setup for Windows + WSL, managed with [chezmoi](https://chezmoi.io): one repo, applied
separately on the Windows host and inside each WSL distro. Code and toolchains live in WSL;
Windows provides the terminal, fonts and editor.

Everything is themed [Catppuccin Mocha](https://catppuccin.com).

## What you get

**Windows**
- Windows Terminal: Catppuccin scheme and tab theme, JetBrainsMono Nerd Font, focus mode, PowerShell 7 as default
- PowerShell 7 profile: Starship prompt with transient prompt, history list (PSReadLine), zoxide, eza with icons
- winget: Git, PowerShell, Windows Terminal, VS Code, gh, chezmoi, Starship, zoxide, delta, bat, eza, ripgrep, fzf, lazygit
- JetBrainsMono Nerd Font installed per user from the official release (no admin)
- `.wslconfig`: memory/CPU limits, mirrored networking

**WSL (Ubuntu, latest LTS)**
- zsh with Starship, autosuggestions, syntax highlighting, zoxide, fzf, eza
- Docker Engine (no Docker Desktop) + lazydocker
- .NET SDK (LTS) via [dotnetup](https://learn.microsoft.com/dotnet/core/tools/dotnetup/), Node (LTS) via [mise](https://mise.jdx.dev)
- gh, lazygit, ripgrep, fd, bat, jq, tmux, delta
- Git uses Windows' Git Credential Manager, so you sign in once for both sides

**Both**: one git config (delta diffs, rebase on pull, zdiff3), one Starship prompt, Catppuccin
for bat, delta, lazygit and fzf.

## Bootstrap

**Windows** (PowerShell):

```powershell
winget install twpayne.chezmoi
chezmoi init --apply henriklanner   # asks for git name/email, installs packages
wsl --install -d Ubuntu             # needs admin, then reboot
```

Restart Windows Terminal afterwards to pick up the font and theme.

**WSL** (Ubuntu):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply henriklanner
```

Asks for your sudo password for apt. If systemd had to be enabled for Docker, it says so: run
`wsl --shutdown` from Windows and reopen Ubuntu.

## Daily use

```bash
chezmoi edit ~/.zshrc     # edit the source, not the file in ~ (apply would overwrite it)
chezmoi diff              # preview what apply would change
chezmoi apply             # apply
chezmoi cd                # jump into the repo to commit/push
chezmoi update            # pull + apply (run on each machine and in each WSL distro)
chezmoi update --init     # same, after .chezmoi.toml.tmpl changed
```

### Shell shortcuts

| Keys / command | pwsh | zsh |
|---|---|---|
| `ls` / `l` / `ll` | eza grid / long / long + hidden, with icons and git status | same |
| `dir`, `gci` | Get-ChildItem, still returns objects | – |
| Typing | history list below the prompt (F2 toggles inline) | grey inline suggestion, → accepts |
| ↑ / ↓ | history starting with what's typed | same |
| Ctrl+R | PSReadLine reverse search | fzf history list |
| `z <dir>` | zoxide jump | same |
| `lg` / `lzd` | lazygit / – | lazygit / lazydocker |

## Layout

| Path in repo | Lands at | On |
|---|---|---|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | both (templated per OS) |
| `dot_config/git/ignore` | `~/.config/git/ignore` | both |
| `dot_config/starship.toml` | `~/.config/starship.toml` | both |
| `dot_zshrc` | `~/.zshrc` | WSL |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` | WSL |
| `dot_config/bat/`, `dot_config/lazygit/` | `~/.config/...` | WSL |
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | `$PROFILE` | Windows |
| `AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/modify_settings.json` | Windows Terminal `settings.json` (merged, see below) | Windows |
| `AppData/Roaming/bat/`, `AppData/Local/lazygit/` | bat and lazygit config | Windows |
| `dot_wslconfig` | `%USERPROFILE%\.wslconfig` | Windows |
| `.chezmoitemplates/` | shared content: Terminal settings, bat and lazygit config | – |
| `.chezmoiexternal.toml.tmpl` | downloads: Nerd Font, bat theme, delta theme | both |
| `.chezmoiscripts/windows/` | winget installs, font registration, bat cache | Windows |
| `.chezmoiscripts/linux/` | apt + installers, bat cache, `mise install` | WSL |

- `.chezmoiignore` decides which files apply on which OS.
- `.chezmoi.toml.tmpl` asks for name/email once per machine, detects WSL, and runs chezmoi's `.ps1` scripts with a process-only `-ExecutionPolicy Bypass`.
- Scripts are `run_onchange_`: they rerun only when their content (or the files they hash) changes.

## Notes

- **Windows Terminal settings are merged, not replaced.** Terminal writes to its own `settings.json`,
  so the modify template only sets the keys in `.chezmoitemplates/windows-terminal.json` and keeps
  generated profiles and UI changes. Change Terminal settings there, not in the Terminal UI, if they should stick.
- **Pinned downloads.** The Nerd Font, bat theme and delta theme are pinned to a release/commit and
  verified by sha256 in `.chezmoiexternal.toml.tmpl`. To upgrade, change the URL and the checksum.
- **dotnetup**: use `dotnetup update` and `dotnetup install` (reads `global.json`). Avoid bare
  `dotnetup` / `dotnetup init`: they offer to edit the shell profile, which chezmoi owns.
- **Docker** runs only inside WSL. Containers' ports are reachable on `localhost` from Windows
  thanks to mirrored networking; Docker from PowerShell or Visual Studio's container tools won't work.
- Machine-specific zsh settings go in `~/.zshrc.local` (not in the repo).
