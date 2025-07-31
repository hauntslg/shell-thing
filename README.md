# Shell
Your little tool to make PowerShell completely yours, and.. you know, helpful. This adds a whole bunch of customisation, new functions, and other things that i haven't really thought about but will probably add later
i'll probably come up with a better name, but let's be real that's unlikely
## Installation
### Step 1
To get this running, all you need to do is unzip this whole project (specifically the folders and the .ps1 file) and put it into your desired directory. 
by default, it is set to `$HOME/shell` 
(use your command terminal to find where $HOME is on your system)
### Step 2
Next, you want to get your functions and directories working properly.

Next, you will need to configure your PowerShell profile. to do this, open up your terminal and type in `notepad $PROFILE`
once you're here, all you need to do is copy paste these in:
``` PowerShell
. "$HOME\shell\shell.ps1"
```
and that's it! it should be prepared the next time you open up PowerShell
### Step 3
Finally, you want to install the required dependencies.
just type in `shell dependencies` and it will scan through the entire list to see if you have every single of the many many dependencies (one dependency) you need for the project to function.
## Contribution
i mean, this is private rn but i don't really mind if anyone else wants to use or modify this
## Commands
type in `Invoke-ShellHelp` for a list of commands :3
`help` was taken so i gotta- I CAN WRITE HELP COMMANDS FOR SHELL??????
## To Do:
Write help commands for each command
test if moving the project folder works and doesn't make my project want to commit big wall of red errors
test removing and adding commands
consider adding aliases maybe