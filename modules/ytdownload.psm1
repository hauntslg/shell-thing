Set-Alias -Name ytd -Value ytdownload
<#
    .SYNOPSIS
    Basic functionality for yt-dlp
    https://github.com/yt-dlp/yt-dlp

    .DESCRIPTION
    Downloads a youtube video into your current directory

    .PARAMETER Link
    The youtube link

    .PARAMETER Command
    The command / download type

    .EXAMPLE
    ytd https://www.youtube.com/watch?v=SgMfVnEm4a4 mp3
#>
function ytdownload {
    param (
        [Parameter(Position = 0)]
        [string]$link,
        [Parameter(Position = 1)]
        [string]$command,
        [Parameter(Position = 2)]
        [string]$filename
    )
    
    if (!$link) {
        Write-Host "Youtube link not provided" -ForegroundColor Red
        Write-Host "Syntax: ytdlp [youtube link] [file type / command] [outmut file name]" -ForegroundColor Yellow
        return
    }

    # Get yt-dlp.exe
    $ytdlp = Join-Path $global:projectDir "data\ytdownload\yt-dlp.exe"

    # non download commands
    switch ($link) {
        "u" { & $ytdlp -U; return }
        "update" { & $ytdlp -U; return }
    }

    # Check and modify $command for aliases
    switch -Wildcard ($command) {
        "ls" { & $ytdlp $link --list-formats; return }
        "list" { & $ytdlp $link --list-formats; return }
        "list*" { & $ytdlp $link --list-formats; return }
        "--list*" { & $ytdlp $link --list-formats; return }
    }

    $arguments = @("-f")

    switch -Regex ($command) {
        "^mp3$" {
            $arguments += @("bestaudio", "--extract-audio", "--audio-format", "mp3")
        }

        "^aac$" {
            $arguments += @("bestaudio", "--extract-audio", "--audio-format", "aac")
        }
        
        "^mp4$" {
            $arguments += @("bestvideo+bestaudio", "--remux-video", "mp4")
        }
        
        "^mkv$" {
            $arguments += @("bestvideo+bestaudio", "--remux-video", "mkv")
        }
        
        Default { & $ytdlp $link --list-formats; return } 
    }

    if ($fileName) {
        $arguments += @("-o", "$filename")
    }

    & $ytdlp $link @arguments
}
