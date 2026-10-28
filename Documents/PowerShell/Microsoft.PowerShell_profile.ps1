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
