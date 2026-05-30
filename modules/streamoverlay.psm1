# rn this is made just for switching the key overlay, but it's designed in a way for modular additions if i ever want any
# i did not know obs and webrequests work but cool lmao, future me problem though

function stream { StreamOverlay @args }
function StreamOverlay {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("keys", "set")]
        [string]$tool,

        [Parameter(Position = 1)]
        [string]$action,

        [Parameter(Position = 2)]
        [string]$secondaryAction
    )

    # save data into config file
    function _SaveConfig($configFile, $configData) {
        $configData |
            ConvertTo-Json -Depth 10 |
            Set-Content $configFile
    }

    # Get current stream config
    function _GetConfig {
        $configDir = Join-Path $global:projectDir "data\streamoverlay"
        $configFile = Join-Path $configDir "config.json"

        if (!(Test-Path $configDir)) {
            New-Item $configDir -ItemType Directory | Out-Null
        }

        # Make a new config file if it does not exist
        if (!(Test-Path $configFile)) {
            [ordered]@{} |
                ConvertTo-Json |
                Set-Content $configFile
        }

        return $configFile
    }
    $configFile = _GetConfig
    $configData = Get-Content $configFile -Raw | ConvertFrom-Json -AsHashtable

    switch ($tool) {
        "keys" {
            # check overlay dir is in the .json
            $overlay = $configData["keyoverlay"]
            if (!$overlay) {
                Write-Host "keyoverlay dir not specified" -ForegroundColor Red
                return
            }

            switch ($action) {
                "set" {
                    $secondaryAction = $secondaryAction.ToLower()

                    # func to end the overlay process and start it again with the updated config
                    function _RestartOverlay($overlayPath) {
                        Get-Process "KeyOverlay" -ErrorAction SilentlyContinue | Stop-Process -Force
                        Start-Process (Join-Path $overlayPath "KeyOverlay.exe")
                    }

                    # check if target config exists
                    $target = Join-Path $overlay "config$secondaryAction.txt" 
                    if (!(Test-Path $target)) {
                        Write-Host "Config file $secondaryAction not found" -ForegroundColor Red
                        return
                    }

                    # swap to and enable the new config
                    Copy-Item $target (Join-Path $overlay "config.txt") -Force
                    $configData["keymode"] = $secondaryAction
                    _SaveConfig $configFile $configData
                    _RestartOverlay $overlay
                }

                # display the current active keymode
                "current" {
                    if (!$configData.ContainsKey("keymode")) {
                        Write-Host "No keymode configured" -ForegroundColor Red
                        return
                    }

                    Write-Host "Current Keymode" -ForegroundColor Yellow
                    Write-Host $configData["keymode"] -ForegroundColor Yellow
                }

                # list all active keymodes
                "list" {
                    $files = Get-ChildItem $overlay -Filter "config*.txt" |
                        Where-Object { $_.Name -ne "config.txt" }

                    Write-Host "Available Keymodes" -ForegroundColor Yellow
                    foreach ($f in $files) {
                        $mode = $f.BaseName.Replace("config", "")
                        Write-Host " - $mode"
                    }
                }
            }
        }

        # general options and settings
        "set" {
            switch ($action) {
                # set the root dir for the key overlay and save it in the config file
                "keyoverlay" {
                    if ($secondaryAction -eq "here") {
                        $secondaryAction = (Get-Location).Path
                    }

                    if (!(Test-Path $secondaryAction)) {
                        Write-Host "Path does not exist" -ForegroundColor Red
                        return
                    }

                    $secondaryAction = (Resolve-Path $secondaryAction).Path
                    
                    $configData["keyoverlay"] = $secondaryAction
                    _SaveConfig $configFile $configData

                    Write-Host "Set keyoverlay to:" -ForegroundColor Yellow
                    Write-Host $secondaryAction -ForegroundColor Yellow
                }
            }
        }
    }
}
