function InitialiseModules($shellVersion) {
    <#
        .SYNOPSIS
            Initialises the Shell Module Manager

        .DESCRIPTION
            Reads pref.ini and loads all modules in the modules/ directory according to user preferences
    #>

    # Get user preferences
    $prefPath = Join-Path $global:projectDir "data\shelldata\pref.json"
    $preferences = @{ # for scope
        Settings = @{
            version = $shellVersion
            projectDir = $global:projectDir
            initMessages = "default"
            initClear = $false
        }
        Modules = @{}
    }

    # Get user preferences from pref.json
    if (Test-Path $prefPath) {
        $preferences = Get-Content $prefPath -Raw | ConvertFrom-Json -AsHashtable

        # check current version
        if ($preferences.Settings.version -ne $shellVersion) {
            $preferences.Settings.version = $shellVersion
        }
    } else {
        # Make sure the shelldata dir exists
        $prefDir = Split-Path $prefPath -Parent
        if (-not (Test-Path $prefDir)) {
            New-Item $prefDir -ItemType Directory | Out-Null
        }

        # Then create a new preferences file
        $preferences | ConvertTo-Json -Depth 3 | Set-Content $prefPath
    }

    # Get modules
    $moduleDir = Join-Path $global:projectDir "modules"
    if (-not (Test-Path $moduleDir)) {
        New-Item $moduleDir -ItemType Directory | Out-Null
    }

    # Sort all modules based on preferences
    $previousModules = $preferences.Modules.Keys
    $currentModules  = Get-ChildItem $moduleDir -File -Filter *.psm1 |
    ForEach-Object { $_.BaseName }

    $existingModules = $currentModules  | Where-Object { $_ -in $previousModules }
    $newModules      = $currentModules  | Where-Object { $_ -notin $previousModules }
    $removedModules  = $previousModules | Where-Object { $_ -notin $currentModules }

    # Add message for return outputs
    $initMessage = @{
        Imported = @()
        Disabled = @()
        Added = @()
        Removed = @()
    }

    # Import new modules and update preferences to have a default value for each module
    foreach ($module in $newModules) {
        $preferences.Modules[$module] = 0

        $modulePath = Join-Path $moduleDir "$module.psm1"
        Import-Module $modulePath

        $initMessage.Added += $module
    }

    # Update for all removed modules
    foreach ($module in $removedModules) {
        $preferences.Modules.Remove($module)
        $initMessage.Removed += $module
    }

    # Update pref.json
    $preferences | ConvertTo-Json -Depth 4 | Set-Content -Path $prefPath

    # Import recognised modules that are set as enabled
    foreach ($module in $existingModules) {
        $importMode = $preferences.Modules[$module]
        $modulePath = Join-Path $moduleDir "$module.psm1"

        # "continue" is illegal inside powershell switches
        if ($importMode -eq "disabled") {
            $initMessage.Disabled += $module
            continue
        }

        # Import all modules
        switch ($importMode) {
            # Enabled
            0 { Import-Module $modulePath -Global }

            # Enable and Run
            { $_ -gt 0 } {
                Import-Module $modulePath -Global
                & $module
            }
            # Lazy Load : Not implemented
            # "lazy" {}
        }

        $initMessage.Imported += $module
    }

    # Return all actions for verbose output
    return $initMessage
}
