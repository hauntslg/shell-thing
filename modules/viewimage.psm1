# Wezterm exclusive rn
Set-Alias -Name vi -Value viewimage
function viewimage {
    param (
        [Parameter(Position = 0)]
        [string]$path
    )

    if (-not $path) {
        Write-Host "No path provided" -ForegroundColor Red
        return
    }

    if ($path -match '^https?://') {
        $tmp = New-TemporaryFile
        Invoke-WebRequest -Uri $path -OutFile $tmp
        wezterm imgcat $tmp
        Remove-Item $tmp
        return
    }

    wezterm imgcat -- "$path"
}
