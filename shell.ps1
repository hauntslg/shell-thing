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
#
# TODO:
#       Update other modules to make up for the removal of $global:prefPath (only banner.psm1 i think)
#       

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
        [string]$module,

        [switch]$detailed,
        [switch]$silent,
        [switch]$default,
        [bool]$cls = $true
    )

    $shellVersion = "0.2.0"

    function _writeInitOutput($initInfo, $initPref) {
        switch ($initPref) {
            "default" {
                foreach ($added in $initInfo.Added) { Write-Host "Added module $added" -ForegroundColor Green }
                foreach ($removed in $initInfo.Removed) { Write-Host "Removed module $removed" -ForegroundColor Red }
            }

            "detailed" {
                foreach ($imported in $initInfo.Imported) { Write-Host "Module $imported Imported" -ForegroundColor Cyan }
                foreach ($disabled in $initInfo.Disabled) { Write-Host "Module $disabled Disabled" -ForegroundColor Yellow }
                foreach ($added in $initInfo.Added) { Write-Host "Added module $added" -ForegroundColor Green }
                foreach ($removed in $initInfo.Removed) { Write-Host "Removed module $removed" -ForegroundColor Red }
            }

            "silent" {}
        }
    }

    $prefPath = Join-Path $global:projectDir "data\shelldata\pref.json"
    switch ($action) {
        "version" {
            Write-Host "creative name for a PowerShell Module Manager" -ForegroundColor Yellow
            Write-Host "version $shellVersion" -ForegroundColor Yellow
        }

        "init" {
            # Initialise the environment with an external script
            Import-Module (Join-Path $global:projectDir ".\data\shelldata\init.psm1")
            $initInfo = InitialiseModules $shellVersion
            Remove-Module init

            # Write output based on settings
            $preferences = Get-Content $prefPath -Raw | ConvertFrom-Json
            $initPref = $preferences.Settings.initMessages
            $clearConsole = $preferences.Settings.initClear

            # Override with switches
            if ($PSBoundParameters.ContainsKey('cls')) { $clearConsole = $cls }

            $switches = @($detailed, $silent, $default) | Where-Object { $_ }
            if ($switches.count -gt 1) {
                Write-Host "Please specify one output at a time" -ForegroundColor Red
                return
            }

            if ($detailed) { $initPref = "detailed" }
            elseif ($silent) { $initPref = "silent" }
            elseif ($default) { $initPref = "default" }

            # Initialisation output
            if ($clearConsole) { Clear-Host }
            _writeInitOutput $initInfo $initPref
        }

        "cd" { Set-Location $global:projectDir }

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
                "ii" { Invoke-Item $prefPath }

                # Write preferences to console
                Default { Get-Content $prefPath }
            }
        }

        Default {
            Write-Host "psmm is working yippee" -ForegroundColor Green
        }
    }
}



# Initialisation
$global:projectDir = $PSScriptRoot
shell init
