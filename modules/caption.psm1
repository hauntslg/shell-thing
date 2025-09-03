function caption {
    param (
        [Parameter(Position = 0)]
        [string]$imgPath,
        [Parameter(Position = 1)]
        [string]$captionText,
        [Parameter(Position = 2)]
        [string]$outputName
    )
    
    # Find the virtual environment 
    $venvPy = Join-Path $global:pref.Settings.projectDirectory ".\tools\imagecaptioner\venv\Scripts\activate"

    # Find script
    $scriptPath = Join-Path $global:pref.Settings.projectDirectory ".\tools\imagecaptioner\ImageCaptioner.py" 

    # Execute the command
    if (-not $outputName.EndsWith(".png")) {
        $outputName += ".png"
    }

    & $venvPy $scriptPath $imgPath $outputName $captionText
}