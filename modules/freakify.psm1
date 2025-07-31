function freakify {
    param(
        [Parameter(Position = 0)]
        [string]$input
    )

    $stringBuilder = [System.Text.StringBuilder]::new()
    # Read each character in the string one by one
    foreach($char in $input.ToCharArray()) {
        # from the character, find matching capital letters and record their modified unicode value
        if($char -match "[A-Z]") {
            $offset = [int][char]$char - [int][char] "A"
            $unicodePoint = 0x1D400 + $offset
        } 
        # from the character, find matching lowercase letters and record their modified unicode value
        elseif ($char -match "[a-z]") {
            $offset = [int][char]$char - [int][char] "a"
            $unicodePoint = 0x1D41A + $offset
        } 
        # Otherwise, just write the character anyway
        else {
            $stringBuilder.Append($char) | Out-Null
            continue
        }
        # Convert the unicode values into characters and append them to the string builder
        $unicodeChar = [char]::ConvertFromUtf32($unicodePoint)
        $stringBuilder.Append($unicodeChar) | Out-Null
    }
    return $stringBuilder.ToString()
}