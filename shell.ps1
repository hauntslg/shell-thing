# window title
$host.ui.RawUI.WindowTitle = "Shell"

# help function. Gives little instructions for each function in shell
function Invoke-ShellHelp {
    param (
    [ValidateSet("initialise", "shell", "banner", "greet")]
    [string]$selectedFunction
    )

    switch ($selectedFunction) {
        "initialise" { 
            Write-Host "Resets all global variables and clears the console"  -ForegroundColor Yellow }

        "shell" {
            Write-Host "Contains a bunch of commands primarily for debugging" -ForegroundColor Yellow
            Write-Host "Available Commands:" -ForegroundColor Yellow
            Write-Host "ps1, directory, globals, preferences, dependencies"
        }

        "banner" { 
            Write-Host "Allows you to mess around with your banner" -ForegroundColor Yellow
            Write-Host "Available Commands:" -ForegroundColor Yellow
            Write-Host "add, edit, remove, list, set, view, directories"
        }
        
        "greet" {
            Write-Host "Displays a random greeting (i'm working on it)" 
        }

        Default {
            Write-Host "Available shell modules:" -ForegroundColor Yellow
            # Write-Host "initialise, shell, banner, greet" -ForegroundColor Yellow
            Write-Host "type in `"Invoke-ShellHelp [function]`" to view instructions for a specific function" -ForegroundColor Yellow
        }
    }
}

# Essentially resets all global variables and resets the shell 
# This can be used if you're having issues with linking your project with your .ini
# This can also be used to scan for new modules
# !!! (Not the same as closing and reopening the shell) !!!
function initialise {
    Clear-Host

    # Attempt to import dependencies
    $dependenciesPresent = $true
    try {
        Import-Module PsIni -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to import dependency PsIni" -ForegroundColor Red
        $dependenciesPresent = $false
    }

    if ($dependenciesPresent) {
        # Globals:
        $global:pref
        $global:prefPath
        $global:projectDirectory
        $global:shellModules

        # Get Preferences
        $global:prefPath = Join-Path $env:APPDATA 'shell\pref.ini'
        # Check if .ini file exists, and create it if it doesn't
        if (!(Test-Path $global:prefPath)) {
            $defaultLocation = Join-Path $HOME "shell"
            $global:pref = @{
                Settings = @{
                    projectDirectory = $defaultLocation

                    # Move these into their own modules
                    bannerDirectory = Join-Path $defaultLocation "banners"
                    currentBanner = "banner.txt"
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


        # Find project directory
        $global:projectDirectory = Join-Path $global:pref.Settings.projectDirectory ""

        # Find modules in project directory
        $modulePath = Join-Path $global:projectDirectory "modules"
        $modules = Get-ChildItem -Path $modulePath -Filter *.psm1

        # Check for new modules and import them
        $initialModules = $global:pref.ShellModules
        $newModules = 0
        foreach ($module in $modules) {
            $moduleName = $module.BaseName
            if (-not ($global:pref.ShellModules.Module -eq $moduleName)) {
                $global:pref.ShellModules.$moduleName = $moduleName

                Write-Host "importing module $moduleName"
                Import-Module "$HOME\shell\modules\$moduleName.psm1"

                Write-Host "Module $module added successfully" -ForegroundColor Green
                $newModules ++
            }
        }

        # Remove any modules that are in the .ini, but not in the modules folder
        $removedModules = Compare-Object $initialModules $global:pref.ShellModules |
            Where-Object { $_.SideIndicator -eq "<=" } |
            Select-Object -ExpandProperty InputObject

        foreach ($name in $removedModules) {
            $global:pref.ShellModules = $global:pref.ShellModules |
                Where-Object { $_.Module -ne $name }
            Write-Host "Module $module removed" -ForegroundColor Yellow
        }

        # Save new modules
        $global:pref.ShellModules = $global:pref.ShellModules
        $global:pref.ShellModules | Format-List
        Export-Ini -InputObject $global:pref -Path $global:prefPath

        # If .ini file does not show the project directory
        if (-not $global:projectDirectory) {
            Write-Host "Your .ini does not link your project directory. please add it in" -ForegroundColor Red
            Write-Host ".ini location:  $global:prefPath" -ForegroundColor Yellow
            Write-Host "write in `"projectDirectory=[file location]`"" -ForegroundColor Yellow
        } else {

            # Maybe make a new function that enables and disables these since they are separate functions? idk, i'll figure it out probably
            if (Test-Path $global:pref.Settings.bannerDirectory) {
                banner
            }
            greet
        }
    }
}

function shell {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("ps1", "directory", "globals", "preferences", "dependencies")]
        [string]$action,

        [Parameter(Position = 1)]
        [ValidateSet("open", "update", "view")]
        [string]$altAction,

        [Parameter(Position = 2)]
        [ValidateSet("path")]
        [string]$openPath

    )
    
    switch ($action) {
        # Opens startup.ps1 in visual studio code
        "ps1" {
            $projectFile = Join-Path $global:projectDirectory "startup.ps1"
            # If THIS FILE exists in the project directory
            if (Test-Path $projectFile) {
                # if the user does not have visual studio code / the "code" command
                if (Get-Command "code" -ErrorAction SilentlyContinue) {
                    code $projectFile
                } else {
                    Write-Host "It appears that you do not have Visual Studio Code installed" -ForegroundColor Red
                    Write-Host "If it is already installed open VSCode and press Ctrl + Shift + P" -ForegroundColor Yellow
                    Write-Host "Run this: Shell Command: install 'code' command in PATH" -ForegroundColor Yellow
                    Write-Host "It should do the rest itself. then you can restart your terminal" -ForegroundColor Yellow
                }
            } else {
                Write-Host "if you see this error, i blame you for this" -ForegroundColor Red
            }
        }

        
        "directory" {
            if (Test-Path $global:projectDirectory) {
                if ($altAction -eq "open") {
                    Invoke-Item $global:projectDirectory
                } else {
                    Write-Host "Project Directory:   $global:projectDirectory" -ForegroundColor Yellow
                }
            } else {
                Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
                Write-Host "Test-Path `$global:projectDirectory failed" -ForegroundColor Yellow
            }
        }

        # Display all global variables
        "globals" {
            Write-Host "prefPath:                   $global:prefPath" -ForegroundColor Yellow
            Write-Host "pref:                       $global:pref" -ForegroundColor Yellow
            Write-Host "projectDirectory:           $global:projectDirectory" -ForegroundColor Yellow
            Write-Host "shellModules:               $global:shellModules" -ForegroundColor Yellow
        }

        "preferences" {
            if ($altAction -eq "open") {
                if ($openPath -eq "path") {
                    $prefdir = Join-Path $global:prefPath ".."
                    Invoke-Item $prefdir
                } else {
                    Invoke-Item $global:prefPath
                }
            } else {
                Get-Content -Path $global:prefPath | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
            }
        }

        # Check for missing dependencies and ask the user if they want to install them
        "dependencies" {
            # List of currently required dependencies
            $dependencies = @(
                "PsIni"
            )
            $missingModuleCount = 0
            $missingModules = @()
            $response = "N"
            
            # Check if any dependencies in the list are missing
            foreach ($module in $dependencies) {
                if (-not (Get-Module -ListAvailable -Name $module)) {
                    $missingModuleCount ++
                    $missingModules += $module
                    Write-Host "Missing dependency: $module" -ForegroundColor Red
                } else {
                    Write-Host "$module is present" -ForegroundColor Yellow
                }
            }

            # If dependencies are missing, inform user and ask if they want to install them
            if ($missingModuleCount -eq 0) {
                Write-Host "No missing dependencies found" -ForegroundColor Green
            } else {
                Write-Host "$missingModuleCount missing dependencies found" -ForegroundColor Red
                Write-Host "Install them now? [Y]/[N]" -ForegroundColor Yellow
                $response = Read-Host
            }

            if ($response -match "^[Yy]") {
                foreach ($module in $missingModules) {
                    try {
                        Install-Module -Name $module -Force -Scope CurrentUser
                        Write-Host "$module installed successfully" -ForegroundColor Green
                    } catch {
                        Write-Host "$module failed to install" -ForegroundColor Red
                    }
                }
            }
        }

        Default {
            Write-Host "Command not found" -ForegroundColor Red
            Write-Host "Type in `"Invoke-ShellHelp`" for a list of commands" -ForegroundColor Yellow
        }
    }
}

# Startup
initialise
