# window title
$host.ui.RawUI.WindowTitle = "Shell"

$greetings = @(
    "here we are."
    "welcome back."
    "hello again."
)

# Essentially resets all global variables and resets the shell 
# This can be used if you're having issues with linking your project with your .ini
# !!! (Not the same as closing and reopening the shell) !!!
function initialise {
    Clear-Host
    # Get Preferences
    $global:prefPath = Join-Path $env:APPDATA 'shell\pref.ini'
    # Check if .ini file exists, and create it if it doesn't
    if (!(Test-Path $global:prefPath)) {
        $defaultLocation = Join-Path $HOME "shell"
        $global:pref = @{
            Settings = @{
                projectDirectory = $defaultLocation
                bannerDirectory = Join-Path $defaultLocation "banners"
                currentBanner = "banner.txt"
            }
        }

        # Create new .ini with no output
        New-Item -Path $global:prefPath -ItemType File -Force > $null
        Export-Ini -InputObject $global:pref -Path $global:prefPath
        Write-Host "New .ini created" -ForegroundColor Green
    } else {
        $global:pref = Import-Ini -Path $global:prefPath
    }

    # Find project directory
    $global:projectDirectory = Join-Path $global:pref.Settings.projectDirectory ""

    # If .ini file does not show the project directory
    if (-not $global:projectDirectory) {
        Write-Host "Your .ini does not link your project directory. please add it in" -ForegroundColor Red
        Write-Host ".ini location:  $global:prefPath" -ForegroundColor Yellow
        Write-Host "write in `"projectDirectory=[file location]`"" -ForegroundColor Yellow
    } else {

    # find currently set banner
    $global:bannerFile = $global:pref.Settings.currentBanner
    # find banner location
    # $global:bannerDirectory = Join-Path $global:pref.Settings.projectDirectory $global:bannerFile
    $global:bannerDirectory = $global:pref.Settings.bannerDirectory
    # Define banner
    $global:banner =  Join-Path $global:bannerDirectory $global:bannerFile
    }

    if (Test-Path $global:banner) {
        banner
    }
    greet
}

function shell {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("ps1", "directory", "globals", "preferences", "dependencies")]
        [string]$action,

        [Parameter(Position = 1)]
        [switch]$open
    )
    
    switch ($action) {
        # Opens startup.ps1 in visual studio code
        "ps1" {
            $projectFile = Join-Path $global:projectDirectory "startup.ps1"
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
            if (Test-Path $global:projectDirectory) {
                if ($open) {
                    Invoke-Item $global:projectDirectory
                } else {
                    Write-Host "Project Directory:   $global:projectDirectory" -ForegroundColor Yellow
                }
            } else {
                Write-Host "if you see this error, wtf did you do :sob:" -ForegroundColor Red
                Write-Host "Test-Path `$global:projectDirectory failed" -ForegroundColor Yellow
            }
        }

        # Display all global variables
        "globals" {
            Write-Host "prefPath:                   $global:prefPath" -ForegroundColor Yellow
            Write-Host "pref:                       $global:pref" -ForegroundColor Yellow
            Write-Host "projectDirectory:           $global:projectDirectory" -ForegroundColor Yellow
            Write-Host "bannerDirectory:            $global:bannerDirectory" -ForegroundColor Yellow
            Write-Host "bannerFile:                 $global:bannerFile" -ForegroundColor Yellow
            Write-Host "banner:                     $global:banner" -ForegroundColor Yellow
        }

        "preferences" {
            Get-Content -Path $global:prefPath | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
        }

        # Check for missing dependencies and ask the user if they want to install them
        "dependencies" {
            # List of currently required dependencies
            $dependencies = @(
                "PsIni"
            )
            $missingModuleCount = 0
            $missingModules = @()
            $response = "N"
            
            # Check if any dependencies in the list are missing
            foreach ($module in $dependencies) {
                if (-not (Get-Module -ListAvailable -Name $module)) {
                    $missingModuleCount ++
                    $missingModules += $module
                    Write-Host "Missing dependency: $module" -ForegroundColor Red
                } else {
                    Write-Host "$module is present" -ForegroundColor Yellow
                }
            }

            # If dependencies are missing, inform user and ask if they want to install them
            if ($missingModuleCount -eq 0) {
                Write-Host "No missing dependencies found" -ForegroundColor Green
            } else {
                Write-Host "$missingModuleCount missing dependencies found" -ForegroundColor Red
                Write-Host "Install them now? [Y]/[N]" -ForegroundColor Yellow
                $response = Read-Host
            }

            if ($response -match "^[Yy]") {
                foreach ($module in $missingModules) {
                    try {
                        Install-Module -Name $module -Force
                        Write-Host "$module installed successfully" -ForegroundColor Green
                    } catch {
                        Write-Host "$module failed to install" -ForegroundColor Red
                    }
                }
            }
        }

        Default {
            Write-Host "Command not found" -ForegroundColor Red
            Write-Host "Available commands:" -ForegroundColor Yellow
            Write-Host "ps1, directory, globals, preferences" -ForegroundColor Yellow
        }
    }


}

# Creates basic commands for creating and modifying banners
function banner {
    param (
        # Parameter help description
        [Parameter(Position = 0)]
        [ValidateSet("add", "edit", "remove", "list", "set", "view", "directories")]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$name,

        [Parameter(Position = 2)]
        [switch]$open
    )


    switch ($action) {
        "add" {
            if (!(Test-Path $global:bannerDirectory)) {
                Write-Host "Banner directory does not exist" -ForegroundColor Red
                Write-Host "Expected directory: $global:bannerDirectory" -ForegroundColor Yellow
            } elseif (!$name) {
                Write-Host "Enter a banner name" -ForegroundColor Red
            } else {
                $filePath = Join-Path $global:bannerDirectory "$name.txt"

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
                $target = Join-Path $global:bannerDirectory "$name.txt"

                if (Test-Path $target) {
                    Invoke-Item $target
                } else {
                    Write-Host "Banner $name does not exist" -ForegroundColor Red
                }

            } elseif (Test-Path $global:banner) {  #If there is no user input
                Invoke-Item $global:banner
            }  else {
                Write-Host "There is no current banner" -ForegroundColor Red
            }
        }

        "remove" {
            $target = Join-Path $global:bannerDirectory "$name.txt"
            if (Test-Path $target) {
                Remove-Item $target
                Write-Host "Banner $name Deleted" -ForegroundColor Yellow
            } else {
                Write-Host "Banner not found" -ForegroundColor Red
            }
        }

        "list" {
            $list = Get-ChildItem $global:bannerDirectory
            foreach ($i in $list) {
                if ($i.Extension -eq ".txt") {
                    Write-Host $i.name -ForegroundColor Yellow
                } else {
                    Write-Host $i.name -ForegroundColor Cyan
                }
            }
        }

        "set" {
            $target = Join-Path $global:bannerDirectory "$name.txt"

            if (Test-Path $target) {
                $global:pref.Settings.banner = $target
                Export-Ini -InputObject $global:pref -Path $global:prefPath
                Write-Host "Banner set to $name" -ForegroundColor Yellow
            } else {
                Write-Host "Banner $name does not exist" -ForegroundColor Red
            }
        }

        "view" {
            $target = Join-Path $global:bannerDirectory "$name.txt"
            if (Test-Path $target) {
                Get-Content -Path $target -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
            } else {
                 Write-Host "banner $name not found" -ForegroundColor Red
            }
        }

        "directories" {
            Write-Host "global:prefPath:            $global:prefPath" -ForegroundColor Yellow
            Write-Host "global:banner:              $global:banner" -ForegroundColor Yellow
            Write-Host "global:bannerDirectory:     $global:bannerDirectory" -ForegroundColor Yellow
            Write-Host "global:bannerFile:          $global:bannerFile" -ForegroundColor Yellow
        }

        Default {
            if (Test-Path $global:banner) {
                Get-Content -Path $global:banner -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
            } else {
                 Write-Host "banner not found" -ForegroundColor Red
            }
        }
    }
}

function greet {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("add", "edit", "remove", "list", "set", "view", "directories")]
        [string]$display
    )

    switch ($display) {
        "add" {
            
        }

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
