function banner {
param (
        [Parameter(Position = 0)]
        [string]$action = "view",

        [Parameter(Position = 1)]
        [string]$bannerName,

        [switch]$safe,
        [switch]$open
    )

    # add colours maybe?
    # later
    function _showBanner($path) {
        if (Test-Path $path) {
            Get-Content $path -Encoding UTF8 | ForEach-Object {
                Write-Host $_ -ForegroundColor Yellow
            }
        } else {
            Write-Host "Banner not found: $path" -ForegroundColor Red
        }
    }

    # Get the user preferences
    $prefPath = Join-Path $global:projectDir "data\shelldata\pref.json"
    $preferences = Get-Content $prefPath -Raw | ConvertFrom-Json -AsHashtable

    # Check for a set banner
    if (-not $preferences.Settings.ContainsKey("currentBanner")) {
        # Default to no banner on first run
        $preferences.Settings["currentBanner"] = "none"
        $preferences | ConvertTo-Json -Depth 3 | Set-Content $prefPath
    }
    $currentBanner = $preferences.Settings.currentBanner

    # Make sure the banner directory exists
    $bannerDir = Join-Path $global:projectDir "data\banners"
    if (-not (Test-Path $bannerDir)) {
        New-Item $bannerDir -ItemType Directory | Out-Null
    }

    switch ($action) {
        Default {
            # Shorthand for banner view <banner>
            if ($bannerName) {
                $bannerPath = Join-Path $bannerDir "$bannerName.txt"
                _showBanner $bannerPath
            } elseif ($currentBanner -ne "none") {
                $bannerPath = Join-Path $bannerDir "$currentBanner.txt"
                _showBanner $bannerPath
            }
        }

        "view" {
            if (-not $bannerName) {
                if ($currentBanner -eq "none") {
                    Write-Host "No banner set" -ForegroundColor Red
                    return
                }

                # If a banner is set, get the path of the banner and print it to the console
                $bannerPath = Join-Path $bannerDir "$currentBanner.txt"
                _showBanner $bannerPath

            } else {
                # View a user selected banner
                $bannerPath = Join-Path $bannerDir "$bannerName.txt"
                _showBanner $bannerPath
            }
        }

        "add" {
            if (!(Test-Path $bannerDir)) {
                Write-Host "Banner directory does not exist" -ForegroundColor Red
                Write-Host "Expected directory: $bannerDir" -ForegroundColor Yellow
            }
            elseif (!$bannerName) {
                Write-Host "Enter a banner name" -ForegroundColor Red
            }
            else {
                $filePath = Join-Path $bannerDir "$bannerName.txt"

                if (!(Test-Path $filePath)) {
                    Add-Content -Path $filePath -Value "put your banner here!"
                    Write-Host "New banner added: $filePath" -ForegroundColor Green
                    if ($open) {
                        Invoke-Item $filePath
                    }

                }
                else {
                    Write-Host "Banner $bannerName already exists" -ForegroundColor Red
                }
            }
        }

        # Open a banner in notepad
        "edit" {
            if ($bannerName -ne "none") {
                Write-Host "There is no current banner" -ForegroundColor Red
            }

            $target = Join-Path $bannerDir "$bannerName.txt"
            if ($bannerName) {

                if (Test-Path $target) {
                    Invoke-Item $target
                }
                else {
                    Write-Host "Banner $bannerName does not exist" -ForegroundColor Red
                }

            } else  {
                #If there is no user input
                Invoke-Item (Join-Path $bannerDir "$currentBanner.txt")
            }
        }

        # Delete a banner
        "remove" {
            $target = Join-Path $bannerDir "$bannerName.txt"

            if (Test-Path $target) {
                if ($safe) {
                    # ngl i copied this from ai
                    # Sends file to trash as opposed to permanently deleting it
                    Add-Type -AssemblyName Microsoft.VisualBasic
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($target, 'OnlyErrorDialogs', 'SendToRecycleBin')
                    Write-Host "Banner $bannerName sent to trash" -ForegroundColor Yellow
                }
                else {
                    Remove-Item $target
                    Write-Host "Banner $bannerName Deleted" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "Banner not found" -ForegroundColor Red
            }
        }

        # List all available banners
        "list" {
            $list = Get-ChildItem $bannerDir -Filter *.txt
            foreach ($item in $list) {
                if ($item.Extension -eq ".txt") {
                    Write-Host $item.name -ForegroundColor Cyan
                }
                else {
                    Write-Host $item.name -ForegroundColor Yellow
                }
            }
        }

        "set" {
            if ($bannerName -eq "none") {
                $preferences.Settings["currentBanner"] = $bannerName
                $preferences | ConvertTo-Json -Depth 3 | Set-Content $prefPath
                Write-Host "Banner disabled" -ForegroundColor Yellow
                return
            }

            $newDefault = Join-Path $bannerDir "$bannerName.txt"

            if (-not (Test-Path $newDefault)) {
                Write-Host "Banner $bannerName does not exist" -ForegroundColor Red
                return
            }

            $preferences.Settings["currentBanner"] = $bannerName
            $preferences | ConvertTo-Json -Depth 3 | Set-Content $prefPath

            Write-Host "Banner set to $bannerName" -ForegroundColor Green
        }
    }
}
