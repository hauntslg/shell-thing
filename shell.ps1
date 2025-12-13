# TODO:
#       Parameter Validation (ValidateSet)
#       update on "forgot to write this"
#       mods default case
#       mods calls : add a guard if alt action isn't given
#       set case : set up switch case
#       init is imported twice : once in init, once in mods
#       Remove-Module init only done in init block : Never removed in shell mods
#           ^^ perform a switch before the main switch block to see if init is required
#           save a boolean to check if init should be removed
#       update default case from debug : however, "psmm is working yippee" is funny though
#           just make it a help message :sob:
#       move global variable initialisation to top
#
#       .EXAMPLE messages
#       unit tests : hwait why didn't i think of that
#       versioning : yes i should probably do that :sob:
#       logging : optional -Verbose stream
#           ,, i hadn't even considered that
#       i will be keeping projectDir and prefPath since my other modules do require those variables
#           however, i am considering doing a rewrite so they don't need them

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

            # test this later
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
            # Display help message on invalid syntax
            if ([string]::IsNullOrWhiteSpace($altAction) -or [string]::IsNullOrWhiteSpace($module)) {
                Write-Host "Usage:" -ForegroundColor Yellow
                Write-Host " - shell mods enable <module>" -ForegroundColor Cyan
                Write-Host " - shell mods disable <module>" -ForegroundColor Cyan
                Write-Host " - shell mods lazy <module>" -ForegroundColor Cyan
                Write-Host " - shell mods <integer> <module>" -ForegroundColor Cyan
                return
            }

            # Prepare modules and module initialisation script
            $moduleDir = Join-Path $global:projectDir "modules"

            # Make sure all modules are present
            if (!(Test-Path $moduleDir)) {
                Write-Host "Modules directory not found" -ForegroundColor Red
                return
            }

            # Make sure init script is present and import it
            if (-not (Get-Command InitialiseModules -ErrorAction SilentlyContinue)) {
                Write-Host "Initialisation script not found" -ForegroundColor Red
                Write-Host "no modules can be imported" -ForegroundColor Yellow
                return
            }
            Import-Module (Join-Path $global:projectDir ".\data\shelldata\init.psm1")

            # Send user action to init.psm1
            switch ($altAction) {
                "enable" { InitialiseModules $altAction $module }
                "disable" { InitialiseModules $altAction $module }
                "lazy" { InitialiseModules $altAction $module }
                { $altAction -match '^\d+$'} { InitialiseModules $altAction $module } # If the input is an integer

                Default {
                    Write-Host "Unrecognised Action: $altAction" -ForegroundColor Red
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
