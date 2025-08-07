function what {
    Write-Host "idfk man" -ForegroundColor Cyan
}

function shit {
    Write-Host "you clown" -ForegroundColor Cyan
}

function kys {
    # I couldn't figure out another way to get it to write utf8 v(o-o)v
    $dataPath = Join-Path $global:projectDirectory "data\smug.txt"
    Set-Content -Path $dataPath -Value "(≖⩊≖)"
    Get-Content $dataPath | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    Remove-Item $dataPath -Force
}

function fuck {
    Write-Host "watch your fucking language" -ForegroundColor Cyan
}