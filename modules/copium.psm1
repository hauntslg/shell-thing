function what {
    Write-Host "idfk man" -ForegroundColor Cyan
}

function shit {
    $img = Join-Path $global:projectDirectory "data\img\pointandlaugh.png"
    viewitem $img
}

function pogger {
    Write-Host "YIPPEEEEEEE" -ForegroundColor Cyan
}

# i should totally remake The Fuck for powershell...
function fuck {
    Write-Host "sobbing and crying" -ForegroundColor Cyan
}

function say {
    $text = $MyInvocation.Line.Substring($MyInvocation.InvocationName.Length).Trim()
    if ($text -ilike "*sigma*") { 
        Write-Host "YOU CAN'T MAKE ME" -ForegroundColor Yellow 
        return
    }

    Write-Host $text -ForegroundColor Yellow
}

function clever {
    Write-Host ">w>" -ForegroundColor Yellow
}
