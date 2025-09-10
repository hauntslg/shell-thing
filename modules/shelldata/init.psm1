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
            Clear-Host

            # Import modules and dependencies
            $importScript = Join-Path $PSScriptRoot "initialise\import.ps1"
            . $importScript

            # If .ini file shows the project directory
            if ($global:pref.Settings.projectDirectory) {
                # Run all modules with position > 0, in ascending order
                $startupModules = $global:pref.ShellModules.GetEnumerator() |
                    Where-Object { [int]$_.Value -gt 0 } |
                    Sort-Object { [int]$_.Value }

                foreach ($moduleEntry in $startupModules) {
                    $modObj = Get-Module $moduleEntry.Key
                    if ($modObj) {
                        foreach ($fn in $modObj.ExportedCommands.Keys) {
                            & $fn
                        }
                    } else {
                        Write-Host "Module $($moduleEntry.Key) failed to import" -ForegroundColor Red
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
