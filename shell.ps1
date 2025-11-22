# TODO: 
#       comment. i'm gonna hate when i get around to it, but i gotta comment this shit
#       breaking news, i never commented any of it

# # window title
# $host.ui.RawUI.WindowTitle = "Shell"

function shell {
    param (
        [Parameter(Position = 0)]
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

                Default { Write-Host "Project Directory:   $($global:projectDirectory)" -ForegroundColor Yellow }
            }
        }
        else {
            Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
            Write-Host "Test-Path `$global:projectDirectory failed" -ForegroundColor Yellow
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
        # Opens project
        "code" {
            $global:projectDirectory
            # If the project directory exists
            if (!(Test-Path $global:projectDirectory)) {
                Write-Host "if you see this error, literally how" -ForegroundColor Red
                Write-Host "Project directory not found" -ForegroundColor Yellow
                return
            }
            
            # if the user does not have visual studio code / the "code" command
            if (Get-Command "code" -ErrorAction SilentlyContinue -CommandType Application) {
                code $global:projectDirectory
            }
            else {
                Write-Host "Visual Studio Code is not installed" -ForegroundColor Red
                Write-Host "If it is already installed open VSCode and press Ctrl + Shift + P" -ForegroundColor Yellow
                Write-Host "Run this: Shell Command: install 'code' command in PATH" -ForegroundColor Yellow
                Write-Host "It should do the rest itself. then you can restart your terminal" -ForegroundColor Yellow
            }
        }

        # Opens project
        "nvim" {
            # If the project directory exists
            if (!(Test-Path $global:projectDirectory)) {
                Write-Host "if you see this error, literally how" -ForegroundColor Red
                Write-Host "Project directory not found" -ForegroundColor Yellow
                return
            }

            # if the user does not have neovim
            if (Get-Command "nvim" -ErrorAction SilentlyContinue) {
                nvim $global:projectDirectory
            }
            else {
                Write-Host "Neovim is not installed" -ForegroundColor Red
            }
        }

        "dir" { _ShellDirectory }
        
        "directory" { _ShellDirectory }

        # Display all global variables
        "globals" {
            Write-Host "prefPath:                   $global:prefPath" -ForegroundColor Yellow
            Write-Host "pref:                       $global:pref" -ForegroundColor Yellow
            Write-Host "projectDirectory:           $global:projectDirectory" -ForegroundColor Yellow
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
                }
                else {
                    Write-Host "$module is present" -ForegroundColor Yellow
                }
            }

            # If dependencies are missing, inform user and ask if they want to install them
            if ($missingModuleCount -eq 0) {
                Write-Host "No missing dependencies found" -ForegroundColor Green
            }
            else {
                Write-Host "$missingModuleCount missing dependencies found" -ForegroundColor Red
                Write-Host "Install them now? [Y]/[N]" -ForegroundColor Yellow
                $response = Read-Host
            }

            if ($response -match "^[Yy]") {
                foreach ($module in $missingModules) {
                    try {
                        Install-Module -Name $module -Force -Scope CurrentUser
                        Write-Host "$module installed successfully" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "$module failed to install" -ForegroundColor Red
                    }
                }
            }
        }

        Default {
            Write-Host "Command not found" -ForegroundColor Red
        }
    }
}

# Startup
$global:projectDirectory = $PSScriptRoot
$global:prefPath = Join-Path $PSScriptRoot "data\pref.ini"
$shellDataPath = Join-Path $PSScriptRoot "modules\shelldata"
$initPath = Join-Path $shellDataPath "init.psm1"
if (Test-Path $initPath) {
    Import-Module $initPath -Force
    initialise
}
else {
    Write-Host "Failed to initialise shell" -ForegroundColor Red
    Write-Host "init.psm1 not found in \modules\shelldata" -ForegroundColor Yellow
}

