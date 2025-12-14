function banner {
param (
        [Parameter(Position = 0)]
        [string]$action = "view",

        [Parameter(Position = 1)]
        [string]$name,

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
    $preferences = Get-Content $prefPath | ConvertFrom-Json -AsHashtable

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
            if ($name) {
                $bannerPath = Join-Path $bannerDir "$name.txt"
                _showBanner $bannerPath
            } elseif ($currentBanner -ne "none") {
                $bannerPath = Join-Path $bannerDir "$currentBanner.txt"
                _showBanner $bannerPath
            }
        }

        "view" {
            if (-not $name) {
                if ($currentBanner -eq "none") {
                    Write-Host "No banner set" -ForegroundColor Red
                    return
                }

                # If a banner is set, get the path of the banner and print it to the console
                $bannerPath = Join-Path $bannerDir "$currentBanner.txt"
                _showBanner $bannerPath

            } else {
                # View a user selected banner
                $bannerPath = Join-Path $bannerDir "$name.txt"
                _showBanner $bannerPath
            }
        }

        "add" {
            if (!(Test-Path $bannerDirectory)) {
                Write-Host "Banner directory does not exist" -ForegroundColor Red
                Write-Host "Expected directory: $bannerDirectory" -ForegroundColor Yellow
            }
            elseif (!$name) {
                Write-Host "Enter a banner name" -ForegroundColor Red
            }
            else {
                $filePath = Join-Path $bannerDirectory "$name.txt"

                if (!(Test-Path $filePath)) {
                    Add-Content -Path $filePath -Value "put your banner here!"
                    Write-Host "New banner added: $filePath" -ForegroundColor Green
                    if ($open) {
                        Invoke-Item $filePath
                    }

                }
                else {
                    Write-Host "Banner $name already exists" -ForegroundColor Red
                }
            }
        }

        # Open a banner in notepad
        "edit" {
            if ($name) {
                $target = Join-Path $bannerDirectory "$name.txt"

                if (Test-Path $target) {
                    Invoke-Item $target
                }
                else {
                    Write-Host "Banner $name does not exist" -ForegroundColor Red
                }

            }
            elseif (Test-Path $banner) {
                #If there is no user input
                Invoke-Item $banner
            }
            else {
                Write-Host "There is no current banner" -ForegroundColor Red
            }
        }

        # Delete a banner
        "remove" {
            $target = Join-Path $bannerDirectory "$name.txt"

            if (Test-Path $target) {
                if ($safe) {
                    # ngl i copied this from ai
                    # Sends file to trash as opposed to permanently deleting it
                    Add-Type -AssemblyName Microsoft.VisualBasic
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($target, 'OnlyErrorDialogs', 'SendToRecycleBin')
                    Write-Host "Banner $name sent to trash" -ForegroundColor Yellow
                }
                else {
                    Remove-Item $target
                    Write-Host "Banner $name Deleted" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "Banner not found" -ForegroundColor Red
            }
        }

        # List all available banners
        "list" {
            $list = Get-ChildItem $bannerDirectory
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
            $target = Join-Path $bannerDirectory "$name.txt"

            # If the given banner exists, set that as the default
            if (Test-Path $target) {
                $global:pref.Settings.currentBanner = "$name.txt"
                Export-Ini -InputObject $global:pref -Path $global:prefPath
                Write-Host "Banner set to $name" -ForegroundColor Yellow
            }
            else {
                Write-Host "Banner $name does not exist" -ForegroundColor Red
            }
        }

    }
}
