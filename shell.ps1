# TODO: In initialisation, the banners are still being written within initialisation. Move that to banner.psm1
#       When importing modules, make "Join-Path $modulePath "$moduleName.psm1"" one variable
#       When importing modules, try using module objects instead of keys + strings
#       $global:projectDirectory = $global:pref.Settings.projectDirectory    -    why does that line exist again..?
#       comment. i'm gonna hate when i get around to it, but i gotta comment this shit
#       Make `initialise` a parameter of `shell`

# window title
$host.ui.RawUI.WindowTitle = "Shell"

function Invoke-ShellHelp {
    <#
    .SYNOPSIS
    Greets the user with a charming message.

    .DESCRIPTION
    This function just says hello, but with ✨vibes✨. Great for testing if the shell is awake and emotionally present.

    .EXAMPLE
    Say-Hello
    Output: Hello there, fellow shell gremlin 👾

    .NOTES
    Part of the Shell onboarding ritual collection.

    #>
}

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

            # Attempt to import dependencies
            ## Consider _testDependencies function
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
                $global:prefPath = Join-Path $env:APPDATA 'shell\pref.ini'

                # Check if .ini file exists, and create it if it doesn't
                if (!(Test-Path $global:prefPath)) {
                    # Change this to read from $PROFILE instead
                    $projectLocation = $PSScriptRoot
                    $global:pref = @{
                        Settings = @{
                            projectDirectory = $projectLocation

                            # Move these into their own modules
                            bannerDirectory = Join-Path $projectLocation "banners"
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

                # New Modules
                $newModules = @()

                foreach ($module in $modules) {
                    $moduleName = $module.BaseName
                    # If a module in the modules directory is not in the .ini, add it
                    if (-not ($global:pref.ShellModules.Keys -contains $moduleName)) {
                        $global:pref.ShellModules[$moduleName] = "0"

                        Write-Host "importing module $moduleName" -ForegroundColor Yellow
                        Import-Module (Join-Path $modulePath "$moduleName.psm1")

                        Write-Host "Module $module added successfully" -ForegroundColor Green

                        $newModules += $moduleName
                    } else {
                        # Add modules preserving previously saved initialisation order
                        $keyValue = $global:pref.ShellModules[$moduleName]
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

                # If .ini file shows the project directory
                if ($global:projectDirectory) {
                    # Run every module set to run on initialisation
                    $i = 1
                    foreach ($module in $global:pref.ShellModules.Keys) {
                        $position = [int]$global:pref.ShellModules[$module]
                        if ($position -eq $i) {
                            $modObj = Get-Module $module
                            if ($modObj) {
                                $expFn = $modObj.ExportedCommands.Keys
                                foreach ($fn in $expFn) {
                                    & $fn
                                }
                            } else {
                                Write-Host "Module $module failed to import" -ForegroundColor Red
                            }
                            $i++
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
}

function shell {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("code", "directory", "dir", "globals", "preferences", "pref", "dependencies")]
        [string]$action,

        [Parameter(Position = 1)]
        [ValidateSet("open", "update", "view", "cd", "dir")]
        [string]$altAction
    )

    function _ShellDirectory {
        if (Test-Path $global:projectDirectory) {
            switch ($altAction) {
                "open" { Invoke-Item $global:projectDirectory }

                "cd" { Set-Location $global:projectDirectory }

                Default { Write-Host "Project Directory:   $global:projectDirectory" -ForegroundColor Yellow }
            }
        } else {
            Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
            Write-Host "Test-Path `$global:projectDirectory failed" -ForegroundColor Yellow
        }
    }

    function _ShellPreferences {
        switch ($altAction) {
            "open" { Invoke-Item $global:prefPath }

            "dir" { 
                $prefdir = Join-Path $global:prefPath ".." 
                Invoke-Item $prefdir
            }

            "go" {
                $prefdir = Join-Path $global:prefPath ".."
                Set-Location $prefdir
            }

            Default { Get-Content -Path $global:prefPath | ForEach-Object { Write-Host $_ -ForegroundColor Yellow } }
        }
    }
    
    switch ($action) {
        # Opens startup.ps1 in visual studio code
        "code" {
            $projectFile = $global:projectDirectory
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

        "dir" { _ShellDirectory }
        
        "directory" { _ShellDirectory }

        # Display all global variables
        "globals" {
            Write-Host "prefPath:                   $global:prefPath" -ForegroundColor Yellow
            Write-Host "pref:                       $global:pref" -ForegroundColor Yellow
            Write-Host "projectDirectory:           $global:projectDirectory" -ForegroundColor Yellow
            Write-Host "shellModules:               $global:shellModules" -ForegroundColor Yellow
        }

        "preferences" { _ShellPreferences }

        "pref" { _ShellPreferences }

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
