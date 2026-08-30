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


function ok {
    if (Get-Command vi) {
        $pointAndLaugh = Join-Path $global:projectDir ".\data\img\rem.png"
        vi $pointAndLaugh
    } else {
        Write-Host "cool" -ForegroundColor Cyan
    }
}

function pogger {
    Write-Host "HOORAAAAYYYYYYYYYY" -ForegroundColor Cyan
}

function vegeta {
    if (Get-Command vi) {
        $vegeta = Join-Path $global:projectDir ".\data\img\vegeta.gif"
        vi $vegeta
    } else {
        Write-Host "first of all, i am vegina" -ForegroundColor Cyan
    }
}


