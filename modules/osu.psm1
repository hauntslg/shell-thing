function osu {
    param(
        [Parameter(Position = 0)]
        [ValidateSet('fetch', 'cache', 'profile')]
        [string]$action,

        [Parameter(Position = 1)]
        [string]$altAction,

        [Parameter(Position = 2)]
        [ValidateSet('Osu', 'o', 'Taiko', 't', 'Catch', 'c', 'Mania', 'm')] # change this to normalisation instead of adding a ton of validate sets
        # Osu, Taiko, Catch, Mania, in that order
        # o,   t,     c,     m,
        [string]$mode
    )

    # globals and data or something
    $dataDir  = Join-Path $global:projectDir 'shell/data/osu'

    # verify files and dependencies exist

    # Normalise mode
    # could be moved into specific actions or called in a function for the sake of memory, but like
    # powershell is already relatively efficient by itself
    $modeMap = @{
        "Osu" = "osu"
        "o" = "osu"
        "Taiko" = "taiko"
        "t" = "taiko"
        "Catch" = "catch"
        "ctb" = "catch"
        "c" = "catch"
        "Mania" = "mania"
        "m" = "mania"
    }
    if ($mode) {
        $normalisedMode = $modeMap[$mode]
    }

    switch  ($action) {
        "fetch" {
            # api actions
        }

        "cache" {
            # cache management
        }

        "profile" {
            # user profile output
        }

        Default {
            # help message or something, idk
        }
    }
}
