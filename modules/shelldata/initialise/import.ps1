## Imports dependencies and modules

# Attempt to import dependencies
$dependenciesPresent = $true
try {
    Import-Module PsIni -ErrorAction Stop
}
catch {
    Write-Host "Failed to import dependency PsIni" -ForegroundColor Red
    $dependenciesPresent = $false
}

# If dependencies are present, attempt to get data and declare globals
if ($dependenciesPresent) {
    # Check if .ini file exists, and create it if it doesn't
    # .ini location is defined in shell.ps1
    if (!(Test-Path $global:prefPath)) {
        $global:pref = @{
            Settings = @{
                projectDirectory = $env:SHELL_MODULE_MANAGER
            }
            ShellModules = @{}
        }

        # Create new .ini with no output
        New-Item -Path $global:prefPath -ItemType File -Force > $null
        Export-Ini -InputObject $global:pref -Path $global:prefPath
        Write-Host "New .ini created" -ForegroundColor Green
    } else {
        $global:pref = Import-Ini -Path $global:prefPath
    }

    # Find modules in project directory
    $modulePath = Join-Path $global:pref.Settings.projectDirectory "modules"
    $modules = Get-ChildItem -Path $modulePath -Filter *.psm1

    # New Modules
    $newModules = @()

    foreach ($module in $modules) {
        $moduleName = $module.BaseName
        # If a module in the modules directory is not in the .ini, add it
        if (-not ($global:pref.ShellModules.Keys -contains $moduleName)) {
            $global:pref.ShellModules[$moduleName] = "0"

            Write-Host "importing module $moduleName" -ForegroundColor Yellow

            try {
                Import-Module (Join-Path $modulePath "$moduleName.psm1")
                Write-Host "Module $module added successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to import $module" -ForegroundColor Red
            }

            $newModules += $moduleName
        } else {
            # Add modules preserving previously saved initialisation order
            # $keyValue = $global:pref.ShellModules[$moduleName] # why is this here?
            Import-Module (Join-Path $modulePath "$moduleName.psm1")
        }
    }


    $currentModules = Get-ChildItem $modulePath -Filter *.psm1 -File | ForEach-Object { $_.BaseName.Trim().ToLower() }
    $initialModules = $global:pref.ShellModules.Keys | ForEach-Object { $_.Trim().ToLower() }


    # Null-guard just in case
    # doesn't work on my version :(
    # $currentModules = $currentModules ?? @()
    # $initialModules = $initialModules ?? @()

    # Identify modules in the .ini but not in the filesystem
    $removedModules = $initialModules | Where-Object { $_ -notin $currentModules }

    foreach ($name in $removedModules) {
        $global:pref.ShellModules.Remove($name)
        Write-Host "Removed module: $name" -ForegroundColor Yellow
    }




    # Save new modules
    Export-Ini -InputObject $global:pref -Path $global:prefPath
}
