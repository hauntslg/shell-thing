# Shell
My little tool to make PowerShell completely yours, and.. you know, helpful. This adds a whole bunch of customisation, new functions, and other things that i haven't really thought about but will probably add later
i'll probably come up with a better name, but let's be real that's unlikely
# Update! 
i never came up with a better name
## Installation
To get this running, just follow the instructions below :3
i'd reccomend using `git fetch`, but if you'd rather download the file then definitely note steps 1 and 4
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
You will need PsIni for the project to function. the command `shell dependencies` should check and install all required dependencies (only one so far)
alternatively, you can get it with `winget install PsIni`
### Step 4:
Now it will ask you if you trust all the modules in the project (which is why it's recommended to use git fetch instead)
Make sure you say Yes to the one named quicktrust.psm1
Then, just type in `quicktrust` and everything will (probably) sort itself out
## Commands
i'm working on it-
soon you'll be able to type in `help [command name]` to see what each command does
## To Do:
Write help commands for each command
Shell is still based in $HOME and must remain in $HOME (change this)
> i may have changed this but i genuinely don't remember
change `init editOrder`