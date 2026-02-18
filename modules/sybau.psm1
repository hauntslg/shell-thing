<#
    .SYNOPSIS
    Cleans / clears data to reduce messages / errors

    .DESCRIPTION
    Takes a location and clears it by removing temporary actions, repeated lines, etc

    .PARAMETER action
    the selected action
    if the action is in a list of bookmarks (hardcoded for now) it will skip checking $type

    .EXAMPLE
    sybau ./example.txt
    sybau "./example directory"
#>
function sybau {
param (
        [Parameter(Position = 0)]
        [string]$action,
        [Parameter(Position = 1)]
        [string]$altAction
    )

    if (!($action)) {
        banner view sybau # include this banner in .gitignore
        return
    }

    function _ExpandEnvVars($path) {
        return [Environment]::ExpandEnvironmentVariables($path)
    }

    function _CleanFile {
    param ( [string]$file )

        $resolvedPath = Resolve-Path $file 
        if (!(Test-Path $resolvedPath)) {
            Write-Host "File not found" -ForegroundColor Red
            Write-Host $file -ForegroundColor Yellow
            Write-Host $resolvedPath -ForegroundColor Yellow
            return
        }

        # Clear powershell history
        if ((Test-Path $resolvedPath -PathType Leaf) -and ($resolvedPath -like "*.txt")) {
            $lines = Get-Content $resolvedPath

            $cleanedLines = $lines |
            Select-Object -Unique | # Clear duplicates
            Where-Object {
                $_.Trim() -ne ""  -and # Clear all empty lines
                $_ -notmatch '^\s*rm\b' -and # Clear all lines starting with "rm"
                $_ -notmatch '^\s*ssh\b' -and # Clear all lines starting with "ssh"
                $_ -notmatch '^\s*#' -and # Clear all comments
                $_ -notmatch '^\s*:' -and # Clear all lines beginning with a colon
                $_ -notmatch '^\s+' # Clear all lines beginning with a space
            }

            $cleanedLines | Set-Content $resolvedPath

            Write-Host "Cleaned history" -ForegroundColor Green

            Write-Host $resolvedPath -ForegroundColor Yellow
            return
        }

        # Clear nvim shada
        if (Test-Path $resolvedPath -PathType Container) {
            Get-ChildItem $resolvedPath -Recurse -Include "*.tmp*" | Remove-Item -Force
            Write-Host "Removed all .tmp files" -ForegroundColor Green
            Write-Host $resolvedPath -ForegroundColor Yellow
            return
        }

        Write-Host "Unsupported file type" -ForegroundColor Red
    }

    $bookmarkFile = Join-Path $global:projectDir "data/sybau/sybau.json"

    if (!(Test-Path $bookmarkFile)) {
        $bookmarkPath = Join-Path $global:projectDir "data/sybau"
        New-Item $bookmarkPath -ItemType Directory
        New-Item $bookmarkFile -ItemType File
    }

    $rawJson = Get-Content $bookmarkFile -Raw
    $bookmarks = if ($rawJson) { $rawJson | ConvertFrom-Json } else { @{} }

    if ($action -like "list") {
        $bookmarks.PSObject.Properties | ForEach-Object { "$($_.Name): $($_.Value)" }
        return
    }

    if ($bookmarks.PSObject.Properties.Name -contains $action) {
        $expandedPath = _ExpandEnvVars($bookmarks.$action)
        _CleanFile($expandedPath)
        return
    }
    else {
        Write-Host "$action not in list" -ForegroundColor Red
    }

    # add, rm, and cd removed for simplicity
    # may consider them later
}


# C:\Users\GGPC\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
