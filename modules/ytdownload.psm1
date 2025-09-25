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
        [string]$command
    )
    
    if (!$link) {
        Write-Host "Youtube link not provided" -ForegroundColor Red
        Write-Host "Syntax: ytdlp [youtube link] [command]" -ForegroundColor Yellow
        return
    }

    # Get yt-dlp.exe
    $ytdlp = Join-Path $global:projectDirectory "data\ytdownload\yt-dlp.exe"

    # Check and modify $command for aliases
    switch -Wildcard ($command) {
        "ls" { & $ytdlp $link --list-formats; return }
        "list" { & $ytdlp $link --list-formats; return }
        "list*" { & $ytdlp $link --list-formats; return }
        "--list*" { & $ytdlp $link --list-formats; return }
    }

    switch -Regex ($command) {
        "^mp3$" {
            & $ytdlp $link -f bestaudio --extract-audio --audio-format mp3
            return
        }

        "^aac$" {
            & $ytdlp $link -f bestaudio --extract-audio --audio-format aac
            return
        }
        
        "^mp4$" {
            & $ytdlp $link -f bestvideo+bestaudio --remux-video mp4
            return
        }
        
        "^mkv$" {
            & $ytdlp $link -f bestvideo+bestaudio --remux-video mkv
            return
        }
        
        Default { & $ytdlp $link --list-formats; return } 
    }
}
