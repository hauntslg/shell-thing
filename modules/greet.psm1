# This isn't done yet, i'll use this to mess with .json files
# This will be moved to a .json later

# i understand jsons now.
# i am regretting this decision.
$greetings = @(
    "here we are."
    "welcome back."
    "hello again."
    "something new?"
    "don't break anything. again."
    "what is it this time?"
    "back so soon?"
)

function greet {
    param (
        [Parameter(Position = 0)]
        # [ValidateSet("add", "edit", "remove", "list", "set", "view", "directories")]
        [string]$action
    )

    if (-not $action) {
        Write-Host ($greetings | Get-Random) -ForegroundColor Yellow
        return
    }

    switch ($action) {

        "list" { 
            foreach ($i in $greetings) {
                Write-Host $i -ForegroundColor Yellow
            }
        }

        Default {
            Write-Host "Action '$action' not found" -ForegroundColor Red
        }
    }
}

Export-ModuleMember -Function greet
