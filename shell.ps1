function shell {
    <#
        .SYNOPSIS
            Entrypoint for Shell Module Manager

        .DESCRIPTION
            Initialises `shell` on startup and auto loads modules based on preferences

        .PARAMETER
            init    - initialise all modules and environment
            cd      - go to shell directory
            vars    - display global variables
            modules - list loaded modules
            set     - manage a module
            pref    - manage preferences

        .PARAMETER altAction
            init    - cls : clear the console for a freshly loaded environment
                      (Default) : reload all modules
            set     - enable / disable / lazy
                      integers for direct inputs / load order
            pref    - ii : open pref.ini
                      (Default) : write preferences to console

        .PARAMETER module
            A selected module for altAction 'set'

        .NOTES
            PSIni is a required dependency for writing to pref.ini
    #>
param (
        [Parameter(Position = 0)]
        [string]$action,
        [Parameter(Position = 1)]
        [string]$altAction,
        [Parameter(Position = 2)]
        [string]$module
    )

    switch ($action) {
        "init" {
            # Verify Dependencies
            if (!(Get-Module -ListAvailable PSIni)) {
                Write-Host "PSIni not found" -ForegroundColor Red  
                Write-Host "PSIni is required for 'shell' to work" -ForegroundColor Yellow  
                Write-Host "it can be installed with the following command:" -ForegroundColor Yellow  
                Write-Host "Install-Module PSIni -Scope CurrentUser -Force" -ForegroundColor Cyan  
                return
            }

            if ($altAction -eq "cls") { Clear-Host }

            Import-Module (Join-Path $global:projectDir ".\data\shelldata\init.psm1")
            InitialiseModules
            Remove-Module init
        }

        "cd" { Set-Location $global:projectDir }

        "vars" {
            Write-Host "`$global:projectDir : $global:projectDir" -ForegroundColor Yellow
            Write-Host "`$global:prefPath : $global:prefPath" -ForegroundColor Yellow
        }

        "mods" {
            $moduleDir = Join-Path $global:projectDir "$modules"
            Import-Module (Join-Path $global:projectDir ".\data\shelldata\init.psm1")

            if (!(Test-Path $moduleDir)) {
                Write-Host "Module directory not found" -ForegroundColor Red
                return
            }

            switch ($altAction) {
                "enable" { InitialiseModules $altAction $module }
                "disable" { InitialiseModules $altAction $module }
                "lazy" { InitialiseModules $altAction $module }
                { $altAction -is [int] } { InitialiseModules $altAction $module }
                Default {
                    Write-Host "forgot to write this" -ForegroundColor Yellow
                }
            }
        }

        "pref" {
            switch ($altAction) {
                "ii" { Invoke-Item $global:prefPath }

                # Write preferences to console
                Default {
                    Get-Content $global:prefPath
                }
            }
        }

        Default {
            Write-Host "psmm is working yippee" -ForegroundColor Green
        }
    }
}



# Initialisation
$global:projectDir = $PSScriptRoot
$global:prefPath = Join-Path $global:projectDir "data\pref.ini"
shell init
