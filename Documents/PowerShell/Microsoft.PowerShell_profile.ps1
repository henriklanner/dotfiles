# PowerShell 7 profile (Windows) — managed by chezmoi

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
    # Collapse previous prompts in scrollback to just ❯
    function Invoke-Starship-TransientFunction { &starship module character }
    Enable-TransientPrompt
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-Alias lg lazygit

# Get-ChildItem/dir: blue directory names instead of the default blue background
$PSStyle.FileInfo.Directory = "`e[34;1m"

# ls/l/ll via eza with icons, same as zsh in WSL. dir/gci still return objects for pipelines.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons=auto --group-directories-first @args }
    function l  { eza -l --icons=auto --group-directories-first --git @args }
    function ll { eza -la --icons=auto --group-directories-first --git @args }
}
