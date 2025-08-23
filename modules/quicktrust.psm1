function quicktrust {
    <#
    .SYNOPSIS
    A quick tool for trusting every module inside of the shell modules directory.

    .DESCRIPTION
    Iterates through all modules listed in $global.pref.ShellModules and asks the user 
    for confirmation before enabling them.

    .PARAMETER <none>

    .EXAMPLE
    PS> quicktrust
    # Prompts the user for confirmation and then trusts all modules if any are approved.

    .NOTES
    Has not been tested, i have no idea if this actually works
    This will become a parameter of `shell` later on
    #>

    $modules = $global:pref.ShellModules.Keys
    $modulesDirectory = Join-Path $global:projectDirectory "modules"
    $confirm = $false # for warning the user about running powershell code

    # Warn user about running modules, because powershell is dumb and can brick your pc 
    Write-Host "Are you sure? [Y/N]" -ForegroundColor Cyan
    Write-Host "Never run powershell code unless you know what it does" -ForegroundColor Yellow
    Write-Host $global.projectDirectory # am i dumb- # yes, i am dumb
    Write-Host "This command will enable..." -ForegroundColor Yellow
    foreach($module in $modules) {
        Write-Host "                            $module" -ForegroundColor Cyan
    }

    $userInput = Read-Host
    
    if($userInput.ToLower() -eq "y") {
        $confirm = $true
    } elseif ($userInput.ToLower() -ne "n") {
        Write-Host "Invalid response" -ForegroundColor ReD
    }

    # If the user says yes (y) trust every module in the modules directory
    if($confirm) {
        foreach($module in $modules) {
            Write-Host "Trusting $module..." -ForegroundColor Yellow
            $modulePath = Join-Path $modulesDirectory "$module.psm1"
            Unblock-File $modulePath
        }
        Write-Host "Success" -ForegroundColor Green
    }
}