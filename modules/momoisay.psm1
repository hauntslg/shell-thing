function momoisay {
    $winPath = "$global:projectDir/data/Momoisay/momoisay"
    $linuxPath = $winPath -replace '\\','/' -replace '^C:/', '/mnt/c/'
    wsl -d Ubuntu bash -c "$linuxPath $args"
}
