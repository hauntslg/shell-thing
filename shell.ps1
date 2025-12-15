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
# CURRENT:
#       Initialisation is complete
#       Now, i'll need to work on setting up preference modifications
#       That includes : <mods> for setting up initialisation behavior
#                       <prefs> for changing general settings
#       I'll also need a decent default message
#       although "psmm is working yippee" is funny
#       would this kinda me a powershell module sandbox?
#       i mean, it's pretty much a mini environment for powershell dev
#       idk, i'll think about it

function shell {
<#
.SYNOPSIS
    PowerShell Module Manager (PSMM) - A dev sandbox for managing your powershell environment and testing modules
    Never came up with a good name for it, idk
    let's call it tim

.DESCRIPTION
    This provides a controlled environment for :
        Automatically initialising modules
        Modifying environment settings
        Easy installation and removal of modules

.PARAMETER action
    The primary performing action
        init        : imports all modules and initialises the environment
        mods        : Manage modules
        pref        : view or modify environment preferences
        cd          : set the current location to the project root
        version     : Displays the current version

.PARAMETER altAction
    The secondary action for each primary action
    for "init":
        -detailed   : displays all information about all detected modules
        -silent     : initialises the environment with no messages
        -default    : only displays new and removed modules
        -cls        : a boolean that can be set to clear the console on initialisation

    for "mods":
        working on it

    for "prefs":
        working on it

.PARAMETER module
    working on it

.EXAMPLE
    Display an info message
        shell

.EXAMPLE
    Display the current version
        shell version

.EXAMPLE
    Initialise the environment
        shell init
        shell init -detailed    : i'll probably change this to -Verbose
        shell init -cls $false

.NOTES
    under heavy development
    Version : 0.2.0
    Author  : boredcat
#>
param (
        [Parameter(Position = 0)]
        [string]$action,
        [Parameter(Position = 1)]
        [string]$altAction,
        [Parameter(Position = 2)]
        [string]$module,

        # Initialisation
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
            Write-Host "PowerShell Sandbox Thing (real)" -ForegroundColor Yellow
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
            # something like this idk
            switch ($altAction) {
                {-not $altAction} { Write-Host write an info message }

                {$altAction -eq "list"} { Write-Host list all modules }

                {$altAction -eq "set"} { Write-Host change a behavior of a selected mod with an external powershell script }
            }

            # more relevant actions can be added later
        }

        "pref" {
            switch ($altAction) {
                # something to change initialisation behavior
                # something else to change the other settings, tbh i forgot them

                # Old code:
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
