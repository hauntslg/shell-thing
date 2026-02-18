Set-Alias -Name sz -Value MeasureSize
function MeasureSize {
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
        [string]$Path = ".",

        [switch]$Recurse,
        [switch]$Directory,  # only directories
        [switch]$File,       # only files
        [ValidateSet("Name","Size")]
        [string]$Sort = "Name"
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    # Convert bytes to human-readable
    function ConvertSize {
        param([long]$Bytes)
        switch ($Bytes) {
            {$_ -ge 1GB} { "{0:N2} GB" -f ($Bytes / 1GB) }
            {$_ -ge 1MB} { "{0:N2} MB" -f ($Bytes / 1MB) }
            {$_ -ge 1KB} { "{0:N2} KB" -f ($Bytes / 1KB) }
            default { "$Bytes Bytes" }
        }
    }

    # Get initial targets
    if (-not $Path -or $Path -eq ".") {
        $targets = Get-Item (Get-Location)
    }
    elseif ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Path)) {
        $targets = Get-ChildItem $Path -Force
        if (-not $targets) { Write-Warning "No items found matching '$Path'"; return }
    }
    else {
        if (-not (Test-Path $Path)) { Write-Host "$Path not found" -ForegroundColor Red; return }
        $targets = Get-Item $Path
    }

    # If -Recurse, expand top-level folders immediately
    $allItems = foreach ($t in $targets) {
        if ($Recurse -and $t.PSIsContainer) {
            Get-ChildItem -LiteralPath $t.FullName -Force -Recurse -ErrorAction SilentlyContinue
        } else {
            $t
        }
    }

    # Filter by -File / -Directory
    if ($File) { $allItems = $allItems | Where-Object { -not $_.PSIsContainer } }
    if ($Directory) { $allItems = $allItems | Where-Object { $_.PSIsContainer } }

    # Build output
    $results = foreach ($i in $allItems) {
        $size = 0L
        if ($i.PSIsContainer) {
            # Folders: try robocopy first for speed
            $roboArgs = @(
                "`"$($i.FullName)`"",
                "`"NUL`"",
                "/L", "/S", "/E",
                "/BYTES",
                "/NJH", "/NJS",
                "/NC", "/NS",
                "/NDL", "/NFL",
                "/MT:16"
            )

            $output = & robocopy @roboArgs 2>&1
            $bytesLine = $output | Where-Object { $_ -match '^\s*Bytes\s*:\s*\d+' } | Select-Object -Last 1
            if ($bytesLine -match '\s*Bytes\s*:\s*(\d+)') {
                $size = [long]$Matches[1]
            } else {
                # fallback to Get-ChildItem if robocopy fails
                $size = (Get-ChildItem -LiteralPath $i.FullName -Recurse -Force -File -ErrorAction SilentlyContinue |
                         Measure-Object Length -Sum).Sum ?? 0L
            }
        } else {
            $size = $i.Length
        }

        [PSCustomObject]@{
            Path          = $i.FullName
            SizeBytes     = $size
            HumanReadable = ConvertSize $size
        }
    }

    # Sort
    if ($Sort -eq "Size") {
        $results = $results | Sort-Object SizeBytes -Descending
    } else {
        $results = $results | Sort-Object Path
    }

    $sw.Stop()
    Write-Host "Execution time: $($sw.Elapsed.TotalMilliseconds)ms"

    return $results
}
