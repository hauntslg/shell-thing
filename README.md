# Shell
Your little tool to make PowerShell completely yours, and.. you know, helpful. This adds a whole bunch of customisation, new functions, and other things that i haven't really thought about but will probably add later
i'll probably come up with a better name, but let's be real that's unlikely
Update! i never came up with a better name
## Installation
To get this running, the best option is to use `git fetch`
otherwise, here's an alternative...
### Step 1:
Download the project (the whole thing) and unzip it somewhere
Copy the location of `shell.ps1` for later
### Step 2:
Open up PowerShell and type in `notepad $PROFILE`
Type this in:
``` PowerShell
# This automatically runs the script whenever you open up the terminal
. "CD:your\project\file\location"
```
### Step 3:
Once that's saved, open up PowerShell and type in `shell dependencies`
If that doesn't work, whoops 🧍
you'll need PsIni for the project to work, `winget install PsIni` should be good
### Step 4:
Now it will ask you if you trust all the modules in the project (which is why it's recommended to use git fetch instead)
Make sure you say Yes to the one names quicktrust.psm1
Then, just type in `quicktrust` and everything will (probably) sort itself out
### Step 5:
Some files may not properly function. this is where the `/data` folder comes in
go to your roaming appdata (`cd $env:APPDATA` to go there quickly in powershell, `ii .` to open up the location)
find a folder simply named "shell" and open that up
just drop the `/data` folder right into there. done!
## Commands
i'm working on it-
## To Do:
Write help commands for each command
Shell is still based in $HOME and must remain in $HOME (change this)
> i may have changed this but i genuinely don't remember
change `init editOrder`