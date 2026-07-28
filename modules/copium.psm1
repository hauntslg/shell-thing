function what {
    Write-Host "idfk man" -ForegroundColor Cyan
}

function shit {
    if (Get-Command vi) {
        $pointAndLaugh = Join-Path $global:projectDir ".\data\img\pointandlaugh.png"
        vi $pointAndLaugh
    } else {
        Write-Host "sobbing and crying" -ForegroundColor Cyan
    }
}

function pogger {
    Write-Host "HOORAAAAYYYYYYYYYY" -ForegroundColor Cyan
}
