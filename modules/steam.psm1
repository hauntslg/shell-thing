function steam {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("list", "run", "cd")]
        [string]$action,
        
        # ** ValueFromRemainingArguments = $true ** takes all other inputs without the need for quotes
        # eg. instead of " 'aim labs' ", you can just do " aim labs "
        [Parameter(Position = 1,  ValueFromRemainingArguments = $true)] # THAT"S A THING? THIS IS PEAK 🗣️🗣️🗣️
        [string]$altAction
    )
    # Default steam files location. if it ain't here, idk why but i blame you for this
    $commonPath = Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common"

    function _GetSteamGames {
        $availableApps = @()
        $allApps = Get-ChildItem $commonPath -Directory

        # Find every installed app by checking for an .exe within each game folder
        foreach($app in $allApps) {
            if(Get-ChildItem $app.FullName -Filter *.exe -File -ErrorAction SilentlyContinue) {
                $availableApps += $app
            }
        }

        # Return both every app (with and without an .exe) in the steam files, 
        # and also every available app (folder with an .exe) in a separate list
        [PSCustomObject]@{
            AllApps = $allApps
            AvailableApps = $availableApps
        }
    }
    
    if(Test-Path $commonPath) {
        # All apps and available apps are separated for error prevention
        $apps = _GetSteamGames
        $allApps = $apps.AllApps
        $availableApps = $apps.AvailableApps

        switch($action) {
            # Lists steam apps in common directory
            "list" {
                # Show every steam app (including unavailable ones)
                if($altAction -eq "all") {
                    foreach($app in $allApps) {
                        if($availableApps -contains $app) {
                            Write-Host $app.Name -ForegroundColor Cyan
                        } else {
                            Write-Host $app.Name -ForegroundColor Yellow
                        }
                    }
                # Show only the available steam apps
                } else {
                    foreach($app in $availableApps) {
                        Write-Host $app.Name -ForegroundColor Cyan
                    }
                }
            }

            # Find an app's .exe and run it
            "run" {
                $match = $availableApps | Where-Object { $_.Name -like "*$altAction*" }
                if($match) {
                    # Select the .exe in the file folder
                    $exe = Get-ChildItem $match.FullName -Filter *.exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if($exe) {
                        Write-Host "Running $match" -ForegroundColor Yellow
                        Start-Process $exe.FullName
                    } else {
                        Write-Host ".exe not found in $altAction" -ForegroundColor Red
                        Write-Host "how tf did you get this error message" -ForegroundColor Yellow
                    }
                } else {
                    # If the app is within the steam directory but is not installed, tell the user
                    $match = $allApps | Where-Object { $_.Name -like "*$altAction*" }
                    if($match) {
                        Write-Host "$match is currently unavailable" -ForegroundColor Red
                        Write-Host "install this app within steam to run it" -ForegroundColor Yellow
                    } else {
                        Write-Host "$altAction not found" -ForegroundColor Red
                    }
                }
            }

            # Navigate to the selected game's location through the terminal
            "cd" {
                $match = $allApps | Where-Object { $_.Name -like "*$altAction*" }
                if ($match.Count -gt 1) {
                    $choice = $match | ForEach-Object { $_.Name } | Out-GridView -Title "Select a game" -PassThru
                    if ($choice) {
                        Set-Location ($match | Where-Object { $_.Name -eq $choice }).FullName
                    }
                } elseif ($match.Count -eq 1) {
                    Set-Location $match[0].FullName
                } else {
                    Write-Host "$altAction not found" -ForegroundColor Red
                }
            }

            Default { 
                Write-Host "Steam directory found" -ForegroundColor Green
                Write-Host "commonPath:     $commonPath" -ForegroundColor Yellow
                Write-Host "Commands: list, all" -ForegroundColor Yellow
                Write-Host "          run," -ForegroundColor Yellow
                Write-Host "          cd," -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "Steam common directory not found" -ForegroundColor Red
        Write-Host "commonPath:     $commonPath" -ForegroundColor Yellow
    }
}