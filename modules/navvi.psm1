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

    $jsonFile = Join-Path $global:pref.Settings.projectDirectory "data/navvi/navvi.json"

    # Make sure the data file exists and is valid
    if (!(Test-Path $jsonFile)) {
        $dataDir = Join-Path $global:pref.Settings.projectDirectory "data/navvi"
        if (!(Test-Path $dataDir)) {
            New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $jsonFile -Force | Out-Null
        '{}' | Set-Content -Encoding UTF8 $jsonFile
    }

    # Turn the json data into a readable format for reading and writing
    function _GetNavviAliases {
        param ($jsonFilePath)

        $aliases = @{}
        if (Test-Path $jsonFilePath) {
            $content = Get-Content -Raw -Path $jsonFilePath
            if ($content.Trim()) {
                try {
                    $temp = $content | ConvertFrom-Json
                    if ($temp -is [PSCustomObject]) {
                        foreach ($key in $temp.PSObject.Properties.Name) {
                            $aliases[$key] = $temp.$key
                        }
                    }
                } catch {
                    Write-Host "Failed to read alias data." -ForegroundColor Red
                }
            }
        }
        return $aliases
    }

    # This line was originally in every switch action
    $aliases = _GetNavviAliases $jsonFile
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
            if ($aliases.Count -eq 0) {
                Write-Host "No aliases found." -ForegroundColor Red
            } else {
                $aliases.GetEnumerator() | Format-Table Name, Value -AutoSize
            }
        }

        "add" {
            # If the location is "here", set it to the current terminal location
            if ($location -eq "here") {
                $location = (Get-Location).Path
            }

            # Add or update the alias
            $aliases[$alias] = $location

            # Save back to JSON
            $aliases | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile

            Write-Host "Saved '$alias' as '$location'" -ForegroundColor Yellow
        }

        "rm" {
            if ($aliases.ContainsKey($alias)) {
                $aliases.Remove($alias)
                $aliases | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile
                Write-Host "Removed alias '$alias'" -ForegroundColor Yellow
            } else {
                Write-Host "Alias '$alias' does not exist." -ForegroundColor Red
            }
        }

        Default { 
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