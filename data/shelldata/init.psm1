# TODO:
#       $set has no validation : can be int or string
#           $set is set up as a [string], so it will never check as an integer
#       Import-Ini : This one is actually fine
#           Get-IniContent and Out-IniFile are from PsIni 3
#           The current latest version is PsIni 4 - it's just poorly documented
#           Import-Ini and Export-Ini are the new functions
#       _LazyUpdate uses $using:modPath in a scriptblock : I'm on ps7+ so this is fine, but i'll definitely note that
#           maybe if i can't do a fix for 5, i'll do a version check
#       continue is illegal inside switch : i actually did not know that
#           use break instead or restructure
#       the module is loaded and executed : comment says load order
#           never sorted by integer value OH that's what i forgot
#       default to 0 and let the user change later : easier to deal with than defaulting every module to lazy
#       only the lazy function is removed, not the entry in the ini
#           hwat
#           oh that's probably on update? that's probably why it won't let me change the load value
#           ,,, idk i forgor
#       i called Export-Ini twice
#       check message colours
#       Import-Module can throw an error : Set up try{}catch{} blocks
#       there's no return value : return a hashtable with loaded, added, removed arrays
#           oh hwait that makes update messages so much easier :sob:

function InitialiseModules {
param (
        [Parameter(Position = 0)]
        [string]$set,
        [Parameter(Position = 1)]
        [string]$module
    )

    # Expect both or neither, not either or
    if ([bool]$set -xor [bool]$module) {
        Write-Host "Missing Var" -ForegroundColor Red
        return
    }

    $ini = Import-Ini $global:prefPath

    # Check if paths exist
    $moduleDir = Join-Path $global:projectDir "modules"
    if (!(Test-Path $moduleDir)) { New-Item $moduleDir -ItemType Directory | Out-Null }
    if (!(Test-Path $global:prefPath)) {
        New-Item $global:prefPath -ItemType File | Out-Null
        "[Settings]`nprojectDirectory=$global:projectDir`n[Modules]`n" | Out-File -FilePath $global:prefPath -Encoding utf8
    }

    function _LazyUpdate {
    param (
            [string]$action,
            [string]$mod
        )

        switch ($action) {
            "add" {
                $modPath = Join-Path $moduleDir "$mod.psm1"
                Set-Item Function:$mod -Value {
                    Remove-Item Function:$mod -ErrorAction SilentlyContinue
                    Import-Module $using:modPath
                    & $mod @PSBoundParameters
                }
                Write-Host "$mod added from $modPath" #debug
            }

            "rm" {
                if (Test-Path Function:$mod) {
                    Remove-Item Function:$mod -ErrorAction SilentlyContinue
                }
            }
        }
    }

    # Change how a single module is loaded
    if ($set) {
        $modulePath = Join-Path $moduleDir "$module.psm1"

        switch ($set) {
            "enable" {
                Import-Module $modulepath
                _LazyUpdate rm $module
                $set = 0
            }

            "disable" {
                Remove-Module $module
                _LazyUpdate rm $module
                $set = -1
            }

            "lazy" {
                Remove-Module $module
                _LazyUpdate add $module
                $set = 'lazy'

            }

            { $set -is [int] } {
                _LazyUpdate rm $module

                if ($set -lt 0) {
                    Remove-Module $module
                } else {
                    Import-Module $module
                }

                continue
            }
        }

        if ($ini['Modules']["$module"] -eq $set) {
            Write-Host "$module already set to $set" -ForegroundColor Yellow
            return
        }

        $ini['Modules']["$module"] = $set
        Export-Ini -InputObject $ini -Path $global:prefPath -Force
        Write-Host "$module set to $set" -ForegroundColor Green

        return
    }

    # Else, reload all modules by reading pref.ini
    # First remove all modules
    $prevModules = @()
    foreach ($mod in $ini['Modules']) {
        $prevModules += $mod
        _LazyUpdate rm $mod
        if (Get-Module -Name $mod) { Remove-Module $mod }
    }

    # Then, load in every module in the modules directory
    $modules = Get-ChildItem $moduleDir -File -Filter *.psm1 | ForEach-Object { $_.BaseName }

    $oldModules = @()
    $newModules = @()
    if (-not $ini.Contains('Modules')) {
        $ini['Modules'] = [System.Collections.Specialized.OrderedDictionary]::new()
    }
    foreach ($mod in $modules) {
        if ($ini['Modules'].Contains($mod)) {
            $flag = $ini['Modules'][$mod]
        } else {
            $flag = "uhh it ain't in there brah"
        }

        # Import every already existing module
        if ($flag -eq "lazy") {
            _LazyUpdate add $mod
            $oldModules += $mod
        }
        if ($flag -is [int]) {
            switch ($flag) {
                0 {
                    Import-Module (Join-Path $moduleDir "$mod.psm1")
                    $oldModules += $mod
                }

                { $_ -gt 0 } {
                    Import-Module (Join-Path $moduleDir "$mod.psm1")
                    & $mod
                    $oldModules += $mod
                }

                { $_ -lt 0 } { $oldModules += $mod }
            }
        }
        else {
            $newModules += $mod
            $ini['Modules'][$mod] = 'lazy'
            _LazyUpdate add $mod
        }
    }
    # Add new modules to list


    $ini | Export-Ini -Path $global:prefPath -Force

    # write a message for every new and every removed module
    $addedModules = $newModules | Where-Object { $_ -notin $prevModules }
    $removedModules = $prevModules | Where-Object { $_ -notin $newModules }

    foreach ($mod in $oldModules) { Write-Host "Loaded '$mod'" -ForegroundColor Yellow }
    foreach ($mod in $addedModules) { Write-Host "Added '$mod'" -ForegroundColor Green }
    foreach ($mod in $removedModules) { Write-Host "Removed '$mod'" -ForegroundColor Yellow }
}
