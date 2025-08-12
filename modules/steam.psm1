function steam {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("list", "run", "cd")]
        [string]$action,
        
        [Parameter(Position = 1,  ValueFromRemainingArguments = $true)] # THAT"S A THING? THIS IS PEAK 🗣️🗣️🗣️
        [string]$altAction
    )
    $commonPath = Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common"

    function _GetSteamGames {
        $availableApps = @()
        $allApps = Get-ChildItem $commonPath -Directory

        # Find every installed app
        foreach($app in $allApps) {
            if(Get-ChildItem $app.FullName -Filter *.exe -File -ErrorAction SilentlyContinue) {
                $availableApps += $app
            }
        }

        [PSCustomObject]@{
            AllApps = $allApps
            AvailableApps = $availableApps
        }
    }

    function _SteamGameMenu {
        $games = _GetSteamGames
        if ($games.Count -eq 0) { return }

        $choices = $games.AvailableApps | ForEach-Object { 
            [PSCustomObject]@{ 
                Game = $_.Name
                Path = $_.FullName
            } 
        }

        $selection = $choices | Out-GridView -Title "🎮 Steam Game Picker (Double-click to launch)" -PassThru

        if ($selection) {
            $exe = Get-ChildItem -Path $selection.Path -Filter "*.exe" -File -ErrorAction SilentlyContinue | 
                Sort-Object Length -Descending | Select-Object -First 1
            if ($exe) {
                Start-Process $exe.FullName
            } else {
                Write-Host "No executable found in $($selection.Path)" -ForegroundColor Yellow
            }
        }
    }
    
    if(Test-Path $commonPath) {
        $apps = _GetSteamGames
        $allApps = $apps.AllApps
        $availableApps = $apps.AvailableApps

        switch($action) {
            # Show all available steam apps
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
                        Start-Process $exe.FullName
                    } else {
                        Write-Host ".exe not found in $altAction" -ForegroundColor Red
                        Write-Host "how tf did you get this error message" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "$altAction not found" -ForegroundColor Red
                }
            }

            # Navigate to the location through the terminal
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

            Default { _SteamGameMenu }
        }
    } else {
        Write-Host "Steam common directory not found" -ForegroundColor Red
        Write-Host "commonPath:     $commonPath" -ForegroundColor Yellow
    }
}