function osu {
    param(
        [Parameter(Position = 0)]
        [ValidateSet('run', 'dir', 'list', 'cd')]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$altAction,

        [Parameter(Position = 2)]
        # Osu, Taiko, Catch, Mania, in that order
        # o,   t,     c,     m,
        [string]$mode
    )
    $dataDir  = Join-Path $env:APPDATA 'shell/data/osu' # make this global? it's always in the same place so idk, probably not
    $configFile = Join-Path $dataDir 'osuConfig.json'

    # Make sure directories exist before saving
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir | Out-Null
    }

    # Safely read JSON, return $null if file missing or malformed
    function Read-JsonFile {
        param([string]$path)
        if (-not (Test-Path $path)) { return $null }
        try {
            $raw = Get-Content -Path $path -Raw -Encoding UTF8
            return $raw | ConvertFrom-Json
        } 
        catch {
            Write-Warning "Could not parse JSON at $path - resetting file."
            return $null
        }
    }

    # Safely write JSON as UTF-8 without BOM
    function Write-JsonFile {
        param([string]$path, [object]$data)
        $json = $data | ConvertTo-Json -Depth 3 -Compress
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($path, $json, $utf8NoBom)
    }

    # A gui that the user sees when they want to look for their osu directory
    # i keep mine in local appdata so this won't show up. which means i can't test it.
    #🧍 italicised :person_standing: emoji
    function _searchGui {
        param(
            [string] $configDir,
            [string] $configFile
        )

        # Prepare and create the gui
        Add-Type -AssemblyName System.Windows.Forms

        $osuDir = $null
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = 'osu! executable|osu!.exe'
        $dialog.Title  = 'Select your osu!.exe'

        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            return $null  # User cancelled
        }

        # If the searched path is invalid, write an error and return null
        $osuDir = Split-Path $dialog.FileName -Parent
        if (-not (Test-Path $osuDir)) {
            Write-Host 'Selected .exe is invalid' -ForegroundColor Red
            Write-Host 'literally how did you get this error' -ForegroundColor Yellow
            return $null
        }

        # Save selection to JSON file in AppData
        Write-JsonFile $configFile @{ directory = $osuDir }
        return $osuDir
    }

    function _findOsu {
        # Check the location in the data file (if it exists) and test that path
        $config = Read-JsonFile $configFile
        if ($config -and $config.directory -and (Test-Path $config.directory)) {
            return $config.directory
        }

        # Check the default location
        $osuDir = Join-Path $env:LOCALAPPDATA 'osu!'
        if (Test-Path $osuDir) { return $osuDir }

        # If both of the above tests fail, open up a gui and request for the location of osu!.exe
        return (_searchGui $dataDir $configFile)
    }



    # Main
    $osuDir = _findOsu
    if(Test-Path $osuDir) {
        $allSongs = Get-ChildItem (Join-Path $osuDir 'Songs') -Directory
        $allSkins = Get-ChildItem (Join-Path $osuDir 'Skins') -Directory
        switch($action) {
            
            'run' {
                $exe = Join-Path $osuDir 'osu!.exe'

                if(Test-Path $exe) {
                    Write-Host 'Starting Osu!...' -ForegroundColor Yellow
                    Invoke-Item $exe
                } else {
                    Write-Host 'osu!.exe not found' -ForegroundColor Red
                    Write-Host 'what did you do :sob:' -ForegroundColor Yellow
                }
            }

            'dir' {
                switch ($altAction) {
                    'cd' {
                        Set-Location $osuDir
                    }

                    # i had some other actions to write but i forgor ._.
                
                    Default {
                        Write-Host $osuDir -ForegroundColor Yellow
                    }
                }
            }

            'list' {
                switch($altAction) {
                    'songs' {
                        $selectSongs = @()

                        switch($mode) {
                            'o' { $mode = '0' }
                            't' { $mode = '1' }
                            'c' { $mode = '2' }
                            'm' { $mode = '3' }
                            Default { $mode = $null }
                        }

                        # If a mode is selected, get .osu files for that mode
                        if ($mode -in @('0', '1', '2', '3')) {
                            $selectSongs = $allSongs | Where-Object { 
                                $osuFiles = Get-ChildItem $_.FullName -Filter *.osu -File
                                if (-not $osuFiles) { return $false }

                                foreach ($file in $osuFiles) {
                                    # Osu files are structurally identical to .ini files, so PsIni would work here
                                    $ini = Get-IniContent $file.FullName
                                    if ($ini['General']['Mode'] -eq $mode) { return $true }
                                }
                                return $false
                             }
                        # Otherwise, just get every song
                        } else {
                            $selectSongs = $allSongs
                        }

                        Write-Host "$($selectSongs.count) songs found" -ForegroundColor Cyan
                        Write-Host 'List them all? [Y/N]' -ForegroundColor Yellow

                        $userResponse = Read-Host
                        $songCounter = 1
                        if($userResponse.ToLower() -eq 'y') {
                            foreach($song in $selectSongs) { 
                                Write-Host "$songCounter - $song" -ForegroundColor Cyan 
                                $songCounter ++
                            }
                        }
                    }
                    
                    'skins' {

                        Write-Host "$($allSkins.count) skins found" -ForegroundColor Cyan
                        Write-Host 'List them all? [Y/N]' -ForegroundColor Yellow

                        $userResponse = Read-Host
                        if($userResponse.ToLower() -eq 'y') {
                            foreach($skin in $allSkins) { Write-Host $skin -ForegroundColor Cyan }
                        }
                    }

                    Default {
                        Write-Host 'Specify "songs" or "skins"' -ForegroundColor Yellow
                    }
                }
            }

            'cd' { # straight up copied from steam.psm1
                $songMatches = $allSongs | Where-Object { $_.Name -like "*$altAction*" } | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name
                        Path = $_.FullName
                        Type = 'Song'
                    }
                } 
                
                $skinMatches = $allSkins | Where-Object { $_.Name -like "*$altAction*" } | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name
                        Path = $_.FullName
                        Type = 'Skin'
                    }
                } 

                $match = $songMatches + $skinMatches
                
                if ($match.Count -gt 1) {
                    # If there's more than one match, open up the gui
                    $choice = $match | Select-Object @{Name='Display';Expression={ $_.Name }}, @{Name='Type';Expression={ $_.Type }} | Out-GridView -Title 'Select a song or skin' -PassThru
                    if ($choice) {
                        $choice.Path
                    }
                } elseif ($match.Count -eq 1) {
                    Set-Location $match[0].Path
                } else {
                    Write-Host "$altAction not found" -ForegroundColor Red
                }
            }

            Default {
                Write-Host 'Osu! found' -ForegroundColor Green
                Write-Host 'Commands: run,' -ForegroundColor Yellow
                Write-Host '          dir,' -ForegroundColor Yellow
                Write-Host '               cd,' -ForegroundColor Yellow
                Write-Host '          list,' -ForegroundColor Yellow
                Write-Host '                songs, (o, t, c, m)' -ForegroundColor Yellow
                Write-Host '                skins,' -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host 'Osu directory not found' -ForegroundColor Red # literally what is wrong with this line
    }
}