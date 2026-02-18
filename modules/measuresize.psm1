Set-Alias -Name size -Value MeasureSize
function MeasureSize {
    param(
            [Parameter(Mandatory=$false, Position=0)]
            [string]$path = "."
         )

    $size = (Get-ChildItem $path -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
    switch ($size) {
        {$_ -ge 1GB} {"$path`: {0:N2} GB" -f ($size / 1GB)}
        {$_ -ge 1MB} {"$path`: {0:N2} MB" -f ($size / 1MB)}
        {$_ -ge 1KB} {"$path`: {0:N2} KB" -f ($size / 1KB)}
        default {"$path`: $size Bytes"}
    }
}
