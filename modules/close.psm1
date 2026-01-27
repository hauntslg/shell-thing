function close {
    <#
    .SYNOPSIS
    closes the terminal, but with a little animation
    .DESCRIPTION
    runs an ASCII animation saved in shell.ps1's data directory
    .EXAMPLE
    close
    #>
    $dataDir = Join-Path $global:projectDir "data/close"
    $player = Join-Path $dataDir "player.js"
    Start-Process node $player -NoNewWindow -Wait
    exit
}

function :q { exit }
