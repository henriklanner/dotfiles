# Installs Windows-side tools with winget. Re-runs automatically whenever this file changes.
$packages = @(
    'Git.Git'
    'Microsoft.PowerShell'
    'Microsoft.WindowsTerminal'
    'Microsoft.VisualStudioCode'
    'GitHub.cli'
    'twpayne.chezmoi'
    'Starship.Starship'
    'ajeetdsouza.zoxide'
    'dandavison.delta'
    'BurntSushi.ripgrep.MSVC'
    'junegunn.fzf'
    'JesseDuffield.lazygit'
    'eza-community.eza'
    # JetBrainsMono Nerd Font comes from the official release via .chezmoiexternal.toml.tmpl
    # Docker runs as Docker Engine inside WSL, see .chezmoiscripts/linux
)

foreach ($id in $packages) {
    winget list --id $id --exact --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ok        $id"
    } else {
        Write-Host "install   $id"
        winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
    }
}
