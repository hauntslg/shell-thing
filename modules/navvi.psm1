# added this instead of set alias
function nav { navvi @args }
function navvi {
<#
    .SYNOPSIS
        Quick navigation using user defined aliases

    .DESCRIPTION
        navvi allows you to add and remove directory locations by your own custom alias
        All aliases are stored in data/navvi.json

        This command supports relative path chaining on top of your quick navigation
        There is an optional interactive menu : navvi.exe

    .PARAMETER action
        add     - Add or overwrite an alias
        rm      - Remove an existing alias
        list    - List all saved aliases
        cd      - Navigate to an alias location explicitly
        <none>  - Launches the TUI menu

    .PARAMETER alias
        The alias being added, removed, or navigated to

    .PARAMETER location
        The directory attached to your alias
        Using 'here' sets your current location
        Relative paths (. & ..) are also resolved

    .EXAMPLE
        Navigate to 'home'
            nav cd home
            nav home

    .EXAMPLE
        Add an alias
            nav add alias here
            nav add users C:\Users

    .EXAMPLE
        Remove an alias
            nav rm users

    .EXAMPLE
        List all existing aliases
            nav list

    .EXAMPLE
        Navigate with relative path chaining
            nav project assets/img

    .EXAMPLE
        Launch the menu
            nav

    .NOTES
        Aliases are all stored in : data/navvi/navvi.json
        Default behavior requires : data/navvi/navvi.exe
#>
param (
        [Parameter(Position = 0)]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$alias,

        [Parameter(Position = 2)]
        [string]$location
    )

    $dataFilePath = Join-Path $global:projectDir "data/navvi"
    $jsonFile = Join-Path $dataFilePath "navvi.json"
    $exePath = Join-Path $dataFilePath "navvi.exe"

    # Make sure the data file exists and is valid
    if (!(Test-Path $jsonFile)) {
        $dataDir = Join-Path $global:projectDir "data/navvi"
        if (!(Test-Path $dataDir)) {
            New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $jsonFile -Force | Out-Null
        '{}' | Set-Content -Encoding UTF8 $jsonFile
    }

    # Turn the json data into a readable format for reading and writing
    function _GetNavviAliases($dataFilePath) {
        try {
            $navData = Get-Content -Raw $dataFilePath | ConvertFrom-Json
            return @($navData)
        } catch {
            Write-Host "Failed to read data file" -ForegroundColor Red
            return @()
        }
    }

    function _AliasesToHashtable($entries) {
        $hashtable = @{}

        foreach ($e in $entries) {
            $hashtable[$e.Name] = $e.Path
        }

        return $hashtable
    }

    # Return entries as an array
    $entries = @(_GetNavviAliases $jsonFile)
    $aliases = _AliasesToHashtable $entries

    function _GetPath($falias) {
        $parts = $falias -split '[\\/]', 2
    
        $baseAlias = $parts[0]
        $relativePath = if ($parts.Count -gt 1) { $parts[1] } else { $null }
    
        if (-not $aliases.ContainsKey($baseAlias)) {
            Write-Host "Alias '$baseAlias' not found." -ForegroundColor Red
            return $null
        }
    
        $base = $aliases[$baseAlias]
    
        if ($relativePath) {
            return Join-Path $base $relativePath
        }
    
        return $base
    }

    switch ($action) {

        # In case an alias name matches one of the commands
        "cd" {
            $relative = _GetPath $alias
            if ($relative) {
                Set-Location $relative
            }
        }

        "list" {
            if ($entries.Count -eq 0) {
                Write-Host "No aliases found." -ForegroundColor Red
            } else {
                $entries | Format-Table Name, Path -AutoSize
            }
        }

        "path" {
            # Get a path from the exe and write it to the console
            $relative = _GetPath $alias
            if ($relative) {
                Write-Output "$relative"
            }
        }

        "add" {
            # If the location is "here", set it to the current terminal location
            if ($location -eq "here") {
                $location = (Get-Location).Path
            }

            # Resolve relative paths like "." or "..\subdir"
            if ($location -match '^[.]{1,2}(\\|/)?') {
                try {
                    $location = Resolve-Path $location | Select-Object -ExpandProperty Path
                } catch {
                    Write-Host "Could not resolve relative path: $location" -ForegroundColor Red
                    return
                }
            }

            # Add / Overwrite alias
            $aliases[$alias] = $location

            # Convert to json format
            $entries = foreach ($key in $aliases.Keys) {
                [PSCustomObject]@{
                    Name = $key
                    Path = $aliases[$key]
                }
            }

            # Save back to JSON
            $entries | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile
            Write-Host "Saved '$alias' as '$location'" -ForegroundColor Yellow
        }

        "rm" {
            if ($aliases.ContainsKey($alias)) {
                # Remove the alias
                $aliases.Remove($alias)

                # Update .json
                $entries = foreach ($key in $aliases.Keys) {
                    [PSCustomObject]@{
                        Name = $key
                        Path = $aliases[$key]
                    }
                }
                $entries | ConvertTo-Json -Depth 2 | Set-Content -Encoding utf8 $jsonFile

                Write-Host "Removed alias '$alias'" -ForegroundColor Yellow
            } else {
                Write-Host "Alias '$alias' not found" -ForegroundColor Red
            }
        }

        Default {
            # Open menu on default (.exe in data folder)
            if (-not $action) {
                # Get a path from the exe
                if (Test-Path $exePath) {
                $returnedPath = & $exePath |
                    Where-Object { $_ -and $_.Trim() } |
                    Select-Object -Last 1

                    # if the exe returns a path, set the location to there
                    if ($returnedPath) {
                        Set-Location -Path $returnedPath
                    }
                } else {
                    Write-Host "navvi.exe not found" -ForegroundColor Red
                }

                return
            }

            $relative = _GetPath $action
            if ($relative) {
                Set-Location $relative
            }
        }
    }
}
