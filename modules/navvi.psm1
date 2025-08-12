Set-Alias -Name nav -Value navvi
function navvi {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("cd", "list", "add", "remove")]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$alias,

        [Parameter(Position = 2)]
        [string]$location
    )

    $jsonFile = Join-Path $global:projectDirectory "data/navvi.json"

    # Make sure the data file exists and is valid
    if (!(Test-Path $jsonFile)) {
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
                    Write-Warning "Failed to read alias data."
                }
            }
        }
        return $aliases
    }

    switch ($action) {
        "cd" {
            # Load aliases
            $aliases = _GetNavviAliases $jsonFile

            if ($aliases.ContainsKey($alias)) {
                Set-Location -Path $aliases[$alias]
            } else {
                Write-Warning "Alias '$alias' not found."
            }
        }

        "list" {
            # Load aliases
            $aliases = _GetNavviAliases $jsonFile

            if ($aliases.Count -eq 0) {
                Write-Host "No aliases found."
            } else {
                $aliases.GetEnumerator() | Format-Table Name, Value -AutoSize
            }
        }

        "add" {
            # If the location is "here", set it to the current terminal location
            if ($location -eq "here") {
                $location = (Get-Location).Path
            }

            # Read and convert existing aliases to hashtable
            $aliases = _GetNavviAliases $jsonFile

            # Add or update the alias
            $aliases[$alias] = $location

            # Save back to JSON
            $aliases | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile

            Write-Host "Saved '$alias' as '$location'"
        }

        "remove" {
            # Load aliases
            $aliases = _GetNavviAliases $jsonFile

            if ($aliases.ContainsKey($alias)) {
                $aliases.Remove($alias)
                $aliases | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $jsonFile
                Write-Host "Removed alias '$alias'"
            } else {
                Write-Warning "Alias '$alias' does not exist."
            }
        }

        Default { 
            #,, idk do jack shit i guess
            Write-Host "Usage: navvi [cd|list|add|remove] [alias] [location]"
         }
    }
}