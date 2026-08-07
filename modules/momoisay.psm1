function momoisay {
    $winPath = "$global:projectDir/data/Momoisay/momoisay"
    $linuxPath = $winPath -replace '\\','/' -replace '^C:/', '/mnt/c/'

    wsl bash -c "$linuxPath $args"
}
