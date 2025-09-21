# Essentially resets all global variables and resets the shell 
# This can be used if you're having issues with linking your project with your .ini
# This can also be used to scan for new modules
# !!! (Not the same as closing and reopening the shell) !!!
Set-Alias -Name init -Value initialise
function initialise {
    param (
    [Parameter(Position = 0)]
    [ValidateSet("order", "editOrder")]
    [string]$action,

    [Parameter(Position = 1)]
    [string]$moduleName,

    [Parameter(Position = 2)]
    [int]$position
    )

    switch ($action) {
        "editOrder" {
            $writeCheck = $true

            # If the module exists
            if ($global:pref.ShellModules.Keys -contains $moduleName) {
                # And the given position is an integer
                if ($position -ge 0) {

                    # For every saved module
                    foreach ($key in $global:pref.ShellModules) {
                        $keyValue = $global:pref.ShellModules[$key]

                        # Check if the initialisation position is already taken
                        if (-not($position -eq 0) -and ($position -eq $keyValue)) {
                            Write-Host "Position $position already taken" -ForegroundColor Red
                            $writeCheck = $false
                        }
                    }
                } else {
                    Write-Host "Invalid position: $position" -ForegroundColor Red
                    $writeCheck = $false
                }
            } else {
                Write-Host "Module $moduleName not found" -ForegroundColor Red
                $writeCheck = $false
            }

            # If the position is not taken, don't the .ini
            # don't change the .ini - typo mb
            # don't the cat
            if ($writeCheck -eq $true) {
                $global:pref.ShellModules[$moduleName] = "$position"
                $global:pref.ShellModules | Format-List
                Export-Ini -InputObject $global:pref -Path $global:prefPath
            }
        }

        "order" {
            foreach ($module in $global:pref.ShellModules.Keys) {
                $keyValue = $global:pref.ShellModules[$module]
                Write-Host "$module = $keyValue"
            }
        }

        Default {
            # Clear-Host

            # Import modules and dependencies
            $importScript = Join-Path $PSScriptRoot "initialise\import.ps1"
            . $importScript

            if ($global:pref.Settings.projectDirectory) {
                $moduleEntries = @($global:pref.ShellModules.GetEnumerator()) # changed this to an array
                $allModules = $moduleEntries | Sort-Object { [int]$_.Value }

                $startupKeys = @()
                    foreach ($entry in $moduleEntries) {
                        $position = [int]$entry.Value
                        if ($position -gt 0) {
                            $startupKeys += $entry.Key
                        }
                    }

                foreach ($moduleEntry in $allModules) {
                    $modulePath = Join-Path $global:pref.Settings.projectDirectory "modules\$($moduleEntry.Key).psm1"

                    Import-Module $modulePath -Force -Global
                    $modObj = Get-Module $moduleEntry.Key

                    if ($startupKeys -contains $moduleEntry.Key) {

                        foreach ($fn in $modObj.ExportedCommands.Keys) {
                            try {
                                & $fn
                            } catch {
                                Write-Warning "Failed to invoke $fn from $($moduleEntry.Key)"
                            }
                        }
                    }
                }
            } else {
                Write-Host "Your .ini does not link your project directory. please add it in" -ForegroundColor Red
                Write-Host ".ini location:  $global:prefPath" -ForegroundColor Yellow
                Write-Host "write in `"projectDirectory=[file location]`"" -ForegroundColor Yellow
            }
        }
    }
}
