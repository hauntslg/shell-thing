Set-Alias -Name vi -Value viewitem
function viewitem {
param (
        [Parameter(Position = 0)]
        [string]$path,
        [string]$force,
        [switch]$Silent,
        [switch]$Async,

        [switch]$ShowChannels,
        [switch]$ShowSampleRate,
        [switch]$ShowSize
    )

    if (-not $path) {
        Write-Host "No path provided" -ForegroundColor Red
        return
    }

    # Open item in browser
    if ($path -match '^https?://') {
        Invoke-Item $path
    }

    # Determine File type (image or audio file)
    # File type can be forced for unrecognised formats
    $filetype
    switch ($force) {
        "image" { $filetype = ".png" }
        "img" { $filetype = ".png" }
        "audio" { $filetype = ".wav" }
        default { $filetype = [System.IO.Path]::GetExtension($path) }
    }

    # All accepted formats
    $imagetypes = @('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.tiff', '.pnm', '.dds', '.tga', '.farbfield')
    $audiotypes = @('.wav', '.mp3', '.ogg', '.flac', '.opus', '.aac', '.m4a', '.wma')

    if ($path -match 'https?://') {
        $tmp = New-TemporaryFile
        Invoke-WebRequest -Uri $path -OutFile $tmp
        wezterm imgcat $tmp
        Remove-Item $tmp
        return
    }

    # Open item with Wezterm's imgcat
    if ($imagetypes -contains $filetype) {
        wezterm imgcat -- "$path"
        return
    }

    # Play audio with ffmpeg
    if ($audiotypes -contains $filetype) {
        # Get audio data as json
        $json = ffprobe -v error -show_format -show_streams -print_format json -- "$path" | ConvertFrom-Json

        $stream = $json.streams | Where-Object { $_.codec_type -eq "audio" }
        $format = $json.format

        $duration = [math]::Round([double]$format.duration, 3)
        $bitrate = [math]::Round($format.bit_rate / 1000)
        $codec = $stream.codec_name
        $channels = $stream.channels
        $samplerate = $stream.sample_rate
        $sizeKB = [math]::Round($format.size / 1024, 2)

        $ShowDuration = $true
        $ShowCodec = $true
        $ShowSize = $true

        if (-not $Silent)      {
            Write-Host "[$($format.filename)]" -ForegroundColor Yellow
            if ($ShowDuration)   { Write-Host "Duration : $duration s" }
            if ($ShowBitrate)    { Write-Host "Bitrate  : $bitrate kbps" }
            if ($ShowCodec)      { Write-Host "Codec    : $codec" }
            if ($ShowChannels)   { Write-Host "Channels : $channels" }
            if ($ShowSampleRate) { Write-Host "Sample   : $samplerate Hz" }
            if ($ShowSize)       { Write-Host "Size     : $sizeKB KB" }
        }

        # Play audio
        if ($Async) {
            Start-Process ffplay -ArgumentList @(
                "-nodisp",
                "-autoexit",
                "-loglevel", "quiet",
                "--", "$Path"
            ) -NoNewWindow 
        } else {
            # Synchronous playback
            & ffplay -nodisp -autoexit -loglevel quiet -- "$Path" | Out-Null
        }

        return
    }

    Write-Host "Item type not recognised" -ForegroundColor Red
}
