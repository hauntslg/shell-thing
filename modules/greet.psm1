# This isn't done yet, i'll use this to mess with .json files
# This will be moved to a .json later

# i understand jsons now.
# i am regretting this decision.
$greetings = @(
    "here we are."
    "welcome back."
    "hello again."
)

function greet {
    param (
        [Parameter(Position = 0)]
        [ValidateSet("add", "edit", "remove", "list", "set", "view", "directories")]
        [string]$display
    )

    switch ($display) {


        "list" { 
            foreach ($i in $greetings) {
                Write-Host $i -ForegroundColor Yellow
            }
        }

        Default {
            Write-Host ($greetings | Get-Random) -ForegroundColor Yellow
        }
    }
}

Export-ModuleMember -Function greet