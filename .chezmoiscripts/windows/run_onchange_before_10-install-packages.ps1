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
    'DEVCOM.JetBrainsMonoNerdFont'
    # 'Docker.DockerDesktop'   # or run Docker Engine inside WSL instead
    # 'JetBrains.Rider'
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
