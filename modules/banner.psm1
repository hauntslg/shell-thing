# Creates basic commands for creating and modifying banners
function banner {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("add", "edit", "remove", "list", "set", "view", "directories")]
        [string]$action = "view",

        [Parameter(Position = 1)]
        [string]$name,
        [switch]$safe,

        [Parameter(Position = 2)]
        [switch]$open
    )

    if (-not $global:pref.Settings.projectDirectory) {
        Write-Host "Project directory not found" -ForegroundColor Red
        Write-Host "Your .ini likely does not have the correct directory" -ForegroundColor Yellow
    }
    else {
        # find currently set banner
        $bannerFile = $global:pref.Settings.currentBanner
        # find banners location, create it if it doesn't exist
        $bannerDirectory = Join-Path $global:pref.Settings.projectDirectory "data/banners"
        if (!(Test-Path $bannerDirectory)) {
            New-Item $bannerDirectory -ItemType Directory
            Write-Host 'New banner data file created'
        }
        # Define banner
        $banner = Join-Path $bannerDirectory $bannerFile
    }
    switch ($action) {
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

        "view" {
            # Default
            if (-not $name) {
                if (Test-Path $banner) {
                    Get-Content -Path $banner -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
                }
                else {
                    Write-Host "banner not found" -ForegroundColor Red
                }

                # View a selected banner
            }
            else {
                $target = Join-Path $bannerDirectory "$name.txt"
                if (Test-Path $target) {
                    Get-Content -Path $target -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
                }
                else {
                    Write-Host "banner $name not found" -ForegroundColor Red
                }
            }
        }

        "directories" {
            Write-Host "global:prefPath:            $global:prefPath" -ForegroundColor Yellow
            Write-Host "banner:                     $banner" -ForegroundColor Yellow
            Write-Host "bannerDirectory:            $bannerDirectory" -ForegroundColor Yellow
            Write-Host "bannerFile:                 $bannerFile" -ForegroundColor Yellow
        }
    }
}

Export-ModuleMember -Function banner