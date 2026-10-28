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

# Inline (grey ghost text, → to accept). ListView leaves "[History]" rows behind in the
# scrollback when combined with Starship's transient prompt. F2 still toggles to ListView.
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Up/Down search history for what's already typed
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

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
