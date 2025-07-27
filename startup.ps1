# window title
$host.ui.RawUI.WindowTitle = "Shell"

$greetings = @(
    "here we are."
    "welcome back."
    "hello again."
)

# Essentially resets all global variables and resets the shell 
# !!! (Not the same as closing and reopening the shell) !!!
function initialise {
    $global:projectDirectory = Join-Path $HOME "!! shell"
    # Get Preferences
    $global:prefPath = "$HOME\!! shell\pref\pref.ini"
    $global:pref = Get-Content $prefPath
    # find currently set banner
    $global:bannerFile = ($pref | Where-Object { $_ -match "^currentBanner="}) -replace "currentBanner=", ""
    # Define banner
    $global:banner = Join-Path "$HOME\!! shell\banners" $bannerFile

    Clear-Host
    if (Test-Path $banner) {
        banner
    }
    greet
}

function shell {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("ps1", "directory")]
        [string]$action,

        [Parameter(Position = 1)]
        [switch]$open
    )
    
    switch ($action) {
        # Opens startup.ps1 in visual studio code
        "ps1" {
            $projectFile = Join-Path $projectDirectory "startup.ps1"
            # If THIS FILE exists in the project directory
            if (Test-Path $projectFile) {
                # if the user does not have visual studio code / the "code" command
                if (Get-Command "code" -ErrorAction SilentlyContinue) {
                    code $projectFile
                } else {
                    Write-Host "It appears that you do not have Visual Studio Code installed" -ForegroundColor Red
                    Write-Host "If it is already installed open VSCode and press Ctrl + Shift + P" -ForegroundColor Yellow
                    Write-Host "Run this: Shell Command: install 'code' command in PATH" -ForegroundColor Yellow
                    Write-Host "It should do the rest itself. then you can restart your terminal" -ForegroundColor Yellow
                }
            } else {
                Write-Host "if you see this error, i blame you for this" -ForegroundColor Red
            }
        }

        
        "directory" {
            if (Test-Path $projectDirectory) {
                if ($open) {
                    Invoke-Item $projectDirectory
                } else {
                    Write-Host "Project Directory:   $projectDirectory" -ForegroundColor Yellow
                }
            } else {
                Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
            }
        }
    }
}

# Creates basic commands for creating and modifying banners
function banner {
    param (
        # Parameter help description
        [Parameter(Position = 0)]
        [ValidateSet("edit", "add", "remove", "list", "set", "paths")]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$name,

        [Parameter(Position = 2)]
        [switch]$open
    )


    $bannerDir = Join-Path $projectDirectory "banners"
    switch ($action) {
        "add" {
            if (!(Test-Path $bannerDir)) {
                Write-Host "Banner directory does not exist" -ForegroundColor Red
                Write-Host "Expected directory: $bannerDir" -ForegroundColor Yellow
            } elseif (!$name) {
                Write-Host "Enter a banner name" -ForegroundColor Red
            } else {
                $filePath = Join-Path $bannerDir "$name.txt"

                if (!(Test-Path $filePath)) {
                    Add-Content -Path $filePath -Value "put your banner here!"
                    Write-Host "New banner added: $filePath" -ForegroundColor Green
                    if ($open) {
                        Invoke-Item $filePath
                    }

                } else {
                    Write-Host "Banner $name already exists" -ForegroundColor Red
                }
            }
        }

        "edit" {
            # If there is user input
            if ($name) {
                $target = Join-Path $bannerDir "$name.txt"

                if (Test-Path $target) {
                    Invoke-Item $target
                } else {
                    Write-Host "Banner $name does not exist" -ForegroundColor Red
                }

            } elseif (Test-Path $banner) {  #If there is no user input
                Invoke-Item $banner
            }  else {
                Write-Host "There is no current banner" -ForegroundColor Red
            }
        }

        "remove" {
            $target = Join-Path $bannerDir "$name.txt"
            if (Test-Path $target) {
                Remove-Item $target
                Write-Host "Banner $name Deleted" -ForegroundColor Yellow
            } else {
                Write-Host "Banner not found" -ForegroundColor Red
            }
        }

        "list" {
            $list = Get-ChildItem $bannerDir
            foreach ($i in $list) {
                if ($i.Extension -eq ".txt") {
                    Write-Host $i.name -ForegroundColor Yellow
                } else {
                    Write-Host $i.name -ForegroundColor Cyan
                }
            }
        }

        "set" {
            $target = Join-Path $bannerDir "$name.txt"

            if (Test-Path $target) {
                Set-Content -Path $prefPath -Value "currentBanner=$name.txt"
                initialise
                Write-Host "Banner set to $name" -ForegroundColor Yellow
            } else {
                Write-Host "Banner $name does not exist" -ForegroundColor Red
            }
        }

        "paths" {
            Write-Host "prefPath:     $prefPath" -ForegroundColor Yellow
            Write-Host "banner:       $banner" -ForegroundColor Yellow
            Write-Host "bannerDir:    $bannerDir" -ForegroundColor Yellow
            Write-Host "bannerFile:   $bannerFile" -ForegroundColor Yellow
        }

        Default {
            if (Test-Path $banner) {
                Get-Content -Path $banner -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
            } else {
                 Write-Host "banner not found" -ForegroundColor Red
            }
        }
    }
}

function greet {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("list")]
        [string]$display
    )

    switch ($display) {
        "list" { 
            foreach ($i in $greetings) {
                Write-Host $i -ForegroundColor Yellow
            }
        }

        Default {
            Write-Host ($greetings | Get-Random) -ForegroundColor Yellow
        }
    }
}

# Startup
initialise
