Set-Alias -Name nav -Value navvi
function navvi {
    param (
        [Parameter(Position = 0)]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$alias,

        [Parameter(Position = 2)]
        [string]$location
    )

    $dataFilePath = Join-Path $global:projectDirectory "data/navvi"
    $jsonFile = Join-Path $dataFilePath "navvi.json"

    # Make sure the data file exists and is valid
    if (!(Test-Path $jsonFile)) {
        $dataDir = Join-Path $global:projectDirectory "data/navvi"
        if (!(Test-Path $dataDir)) {
            New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $jsonFile -Force | Out-Null
        '{}' | Set-Content -Encoding UTF8 $jsonFile
    }

    # Turn the json data into a readable format for reading and writing
    function _GetNavviAliases {
        param ($dataFilePath)

        $entries = @()
        if (Test-Path $dataFilePath) {
            $content = Get-Content -Raw -Path $dataFilePath
            if ($content.Trim()) {
                try {
                    $entries = $content | ConvertFrom-Json
                } catch {
                    Write-Host "Failed to read alias data." -ForegroundColor Red
                }
            }
        }
        return $entries
    }

    function _AliasesToHashtbl {
        param ($entries)
        $htbl = @{}
        foreach ($e in $entries) {
            $htbl[$e.Name] = $e.Path
        }
        return $htbl
    }

    $entries = _GetNavviAliases $jsonFile
    $aliases = _AliasesToHashtbl $entries

    switch ($action) {
        
        # In case an alias name matches one of the commands
        "cd" {
            if ($aliases.ContainsKey($alias)) {
                Set-Location -Path $aliases[$alias]
            } else {
                Write-Host "Alias '$alias' not found." -ForegroundColor Red
            }
        }

        "list" {
            if ($entries.Count -eq 0) {
                Write-Host "No aliases found." -ForegroundColor Red
            } else {
                $entries | Format-Table Name, Path -AutoSize
            }
        }

        "add" {
            # If the location is "here", set it to the current terminal location
            if ($location -eq "here") {
                $location = (Get-Location).Path
            }

            # Remove existing entry with matching name
            $entries = $entries | Where-Object { $_.Name -ne $alias }

            # Add new entry
            $entries += [PSCustomObject]@{ Name = $alias; Path = $location }

            # Save back to JSON
            $entries | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile
            Write-Host "Saved '$alias' as '$location'" -ForegroundColor Yellow
        }

        "rm" {
            $initialCount = $entries.Count
            $entries = $entries | Where-Object { $_.Name -ne $alias }
            if ($entries.Count -lt $initialCount) {
                Write-Host "Removed alias '$alias'" -ForegroundColor Yellow
            } else {
                Write-Host "Alias '$alias' does not exist." -ForegroundColor Red
            }
        }

        Default { 
            # Open menu on default (.exe in data folder)
            if (-not $action) {
                $returnedPath = & (Join-Path $dataFilePath "navvi.exe")
                $returnedPath = $returnedPath | Where-Object { $_.Trim() } | Select-Object -Last 1

                if ($returnedPath) { Set-Location -Path $returnedPath }
                return
            }

            # Quick nav
            if ($aliases.ContainsKey($action)) {
                # Go to saved location  
                Set-Location -Path $aliases[$action]

                # cd from saved location to relative location
                if ($alias) {
                    Set-Location $alias
                }
            } else {
                Write-Host "Alias '$action' not found." -ForegroundColor Red 
            }
        }
    }
}
