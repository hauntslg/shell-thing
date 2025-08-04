Set-Alias -Name nav -Value navvi
function navvi {
    param (
        [Parameter(Position = 0)] 
        [ValidateSet("add", "list", "remove", "go", "open", "code", "run")]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$alias = $null,

        [Parameter(Position = 2)] 
        [string]$location = $null,

        [Parameter(Position = 3)]
        [string]$item = $null
    )

    $dataFolder = Join-Path $global:projectDirectory "data"
    $dataFile = Join-Path $dataFolder "navvi.json"
    switch ($action) {
        # Add location to navvi.json
        "add" {
            # Error prevention
            $writeCheck = $true
            
            # If all inputs are provided and the data folder exists, allow write
            if ([string]::IsNullOrWhiteSpace($alias)) {
                Write-Host "No alias provided" -ForegroundColor Red
                $writeCheck = $false
            } elseif (!(Test-Path $dataFolder)) {
                Write-Host "Data folder not found" -ForegroundColor Red
                $writeCheck = $false
            } elseif ($location -eq $null) {
                Write-Host "Enter a location" -ForegroundColor Red
                $writeCheck = $false
            # If the location input is "here", set the location to the current location in terminal
            }  elseif ($location -eq "here") {
                if ([string]::IsNullOrWhiteSpace($item)) {
                    $location = Join-Path (Get-Location) $item
                } else {
                    $location = Get-Location
                }
            } elseif (!(Test-Path $location)) {
                Write-Host "Item location not found" -ForegroundColor Red
                $writeCheck = $false
            }

            if ($writeCheck -eq $true) {
                # If the data file exists, get data from it. otherwise, make a new one
                if (!(Test-Path $dataFile)) {
                    New-Item $dataFile
                    $jsonData = @()
                } else {
                    $jsonData = Get-Content $dataFile | ConvertFrom-Json
                }
                
                $newEntry = @{
                    alias = $alias
                    path = (Resolve-Path $location).Path
                }
                
                # Check if inputted entry already exists
                $dupeCheck = $jsonData | Where-Object {
                    $_.alias -eq $alias -or $_.path -eq $newEntry.path
                }

                if (!($dupeCheck)) {
                    $jsonData += $newEntry
                    $jsonData | ConvertTo-Json | Set-Content $dataFile
                    Write-Host "Item $alias added for $location" -ForegroundColor Yellow
                } else {
                    Write-Host "Entry already exists" -ForegroundColor Yellow
                    Write-Host $dupeCheck -ForegroundColor Yellow
                }
            }
        }

         # View list of saved navvi locations 
        "list" {
            if (Test-Path $dataFile) {
                Get-Content $dataFile | ConvertFrom-Json | Format-Table
            } else {
                Write-Host ".json data not found"
            }
        }

        # Remove an item from the list
        "remove" {
            # Search for the item
            $jsonData = Get-Content $dataFile | ConvertFrom-Json
            $item = $jsonData | Where-Object {
                $_.alias -eq $alias
            }

            # If the item exists, remove it
            if ($item) {
                $jsonData = $jsonData | Where-Object { $_.alias -ne $alias }
                ConvertTo-Json $jsonData -Depth 10 | Out-File -FilePath $dataFile -Encoding utf8
                Write-Host "Item $alias removed" -ForegroundColor Yellow
                Write-Host "Matching item: $($item | ConvertTo-Json)"
            } else {
                Write-Host "Item $alias not found" -ForegroundColor Red
            }
        }
        
        # open its location 
        "open" {
            # Search for the item
            $jsonData = Get-Content $dataFile | ConvertFrom-Json
            $item = $jsonData | Where-Object {
                $_.alias -eq $alias
            }

            # If the item exists, Invoke-Item
            if ($item) {
                $path = $item.path
                if (Test-Path $path) {
                    Invoke-Item $path
                } else {
                    Write-Host "Path for alias '$alias' not found: $path" -ForegroundColor Red
                }
            } else {
                Write-Host "Item $alias not found" -ForegroundColor Red
            }
        }

        # open in vscode (ironic how i'm making this in vim, eh?)  
        "code" {
            # Search for the item
            $jsonData = Get-Content $dataFile | ConvertFrom-Json
            $item = $jsonData | Where-Object {
                $_.alias -eq $alias
            }

            # If the item exists, Invoke-Item
            if ($item) {
                $path = $item.path
                if (Test-Path $path) {
                    code $path
                } else {
                    Write-Host "Path for alias '$alias' not found: $path" -ForegroundColor Red
                }
            } else {
                Write-Host "Item $alias not found" -ForegroundColor Red
            }
        }

        # Navigate to location in terminal
        "go" {
            # # Search for the item
            # $item = @()
            $jsonData = Get-Content $dataFile | ConvertFrom-Json
            $jsonObj = Get-Content -Path $dataFile -Raw | ConvertFrom-Json
            # $item += $jsonObj | Where-Object { $_.alias -eq $alias }

            # if ($item.Count -gt 0) {
            #     $path = $item[0].path


            #     Write-Host "`$item | Format-List:"
            #     $item | Format-List
            #     Write-Host "`$item[0] | Get-Member"
            #     $item[0] | Get-Member
            #     Write-Host "`$jsonObj | ForEach-Object { `"`$(`$_.alias) → `$(`$_.path)`" }"
                # $jsonObj | ForEach-Object { "$($_.alias) → $($_.path)" }


            #     try {
            #         if (Test-Path $path) {
            #         Set-Location $path
            #         } else {
            #             Write-Host "Path for alias '$alias' not found: $path" -ForegroundColor Red
            #         }
            #     }
            #     catch {
            #         Write-Host "`$path is null" -ForegroundColor Red
            #         Write-Host "path = $path" -ForegroundColor Yellow
            #     }

            # } else {
            #     Write-Host "Item $alias not found" -ForegroundColor Red
            # }

            $item = ($jsonObj | Where-Object { $_.alias -eq $alias }) | Select-Object -First 1
# $item | Get-Member
$jsonObj.GetType().FullName
if ($item -and $item.path) {
    $path = $item.path
    Write-Host "🛸 Path resolved: $path" -ForegroundColor Cyan
    Set-Location $path
} else {
    Write-Host "Could not resolve path for alias '$alias'" -ForegroundColor Red
}
        }

        # find location in terminal
        Default {
        }
    }
}
