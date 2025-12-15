function ModifyPreference {
param(

        [string]$updatingPreference,
        [string]$newValue
    )

    # Verify preferences exist and parse them
    $prefPath = Join-Path $global:projectDir "data\shelldata\pref.json"
    if (-not (Test-Path $prefPath)) { Write-Host "pref.json not found" -ForegroundColor Red; return $false }

    $preferences = Get-Content $prefPath -Raw | ConvertFrom-Json -AsHashtable
    if (-not $preferences) { Write-Host "preferences not found" -ForegroundColor Red; return $false }

    # Check if Settings are being changed
    switch($updatingPreference) {
        "initMessages" {
            if ($newValue -in @("default", "verbose", "silent")) {
                $preferences.Settings[$updatingPreference] = $newValue
                _updateJson $preferences $prefPath
                return $true
            }

            Write-Host "Invalid value" -ForegroundColor Red
            return $false
        }

        "initClear" {
            # Try to convert the new value input to a boolean
            $parsedBool = $false
            if ([bool]::TryParse($newValue, [ref]$parsedBool)) {
                $preferences.Settings[$updatingPreference] = $newValue
                _updateJson $preferences $prefPath
                return $true
            }

            Write-Host "Invalid value" -ForegroundColor Red
            return $false
        }
    }

    # Otherwise, check if a module preference is being changed
    if ($updatingPreference -in $preferences.Modules.Keys) {
        # Try to convert the new value to an integer
        $parsedInt = 0
        if ([int]::TryParse($newValue, [ref]$parsedInt)) {
            $preferences.Modules[$updatingPreference] = $parsedInt
            _updateJson $preferences $prefPath
            return $true
        } elseif ($newValue -in @("enable", "disable")) {
            $preferences.Modules[$updatingPreference] = $newValue
            _updateJson $preferences $prefPath
            return $true
        }

        Write-Host "Invalid value" -ForegroundColor Red
        return $false
    }

    Write-Host "$updatingPreference not found" -ForegroundColor Red
    return $false
}

function _updateJson($updatedPreferences, $prefPath) {
    $updatedPreferences | ConvertTo-Json -Depth 3 | Set-Content $prefPath
}
