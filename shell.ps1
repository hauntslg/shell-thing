# TODO: 
#       comment. i'm gonna hate when i get around to it, but i gotta comment this shit

# # window title
# $host.ui.RawUI.WindowTitle = "Shell"

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
        if (Test-Path $global:pref.Settings.projectDirectory) {
            switch ($altAction) {
                "open" { Invoke-Item $global:pref.Settings.projectDirectory }

                "cd" { Set-Location $global:pref.Settings.projectDirectory }

                Default { Write-Host "Project Directory:   $($global:pref.Settings.projectDirectory)" -ForegroundColor Yellow }
            }
        } else {
            Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
            Write-Host "Test-Path `$global:pref.Settings.projectDirectory failed" -ForegroundColor Yellow
        }
    }

    function _ShellPreferences {
        switch ($altAction) {
            "ii" { Invoke-Item $global:prefPath }

            "dir" { 
                $prefdir = Join-Path $global:prefPath ".." 
                Invoke-Item $prefdir
            }

            "cd" {
                $prefdir = Join-Path $global:prefPath ".."
                Set-Location $prefdir
            }

            Default { Get-Content -Path $global:prefPath | ForEach-Object { Write-Host $_ -ForegroundColor Yellow } }
        }
    }
    
    switch ($action) {
        # Opens startup.ps1 in visual studio code
        "code" {
            $projectFile = $global:pref.Settings.projectDirectory
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
            Write-Host "projectDirectory:           $global:pref.Settings.projectDirectory" -ForegroundColor Yellow
            Write-Host "shellModules:               $global:shellModules" -ForegroundColor Yellow
        }

        "preferences" { _ShellPreferences }

        "pref" { _ShellPreferences }

        # Check for missing dependencies and ask the user if they want to install them
        "dependencies" {
            # List of currently required dependencies
            $dependencies = @(
                "PsIni"
                # add node.js
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
$global:prefPath = Join-Path $PSScriptRoot "data\pref.ini"
$shellDataPath = Join-Path $PSScriptRoot "modules\shelldata"
$initPath = Join-Path $shellDataPath "init.psm1"
if (Test-Path $initPath) {
    Import-Module $initPath -Force
    initialise
} else {
    Write-Host "Failed to initialise shell" -ForegroundColor Red
    Write-Host "init.psm1 not found in \modules\shelldata" -ForegroundColor Yellow
}

