function freakify {
    param(
        [Parameter(Position = 0)]
        [string]$inputString
    )

    $stringBuilder = [System.Text.StringBuilder]::new()
    # Read each character in the string one by one
    foreach($char in $inputString.ToCharArray()) {
        # from the character, find matching capital letters and record their modified unicode value
        if($char -match "(?-i)[A-Z]") {
            $offset = [int][char]$char - [int][char] "A"
            $unicodePoint = 0x1D4D0 + $offset
        }
        elseif($char -match "(?-i)[a-z]") {
            $offset = ([int][char]$char - [int][char] "A") - 6
            $unicodePoint = 0x1D4D0 + $offset
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