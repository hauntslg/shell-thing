# Shell
Your little tool to make PowerShell completely yours, and.. you know, helpful. This adds a whole bunch of customisation, new functions, and other things that i haven't really thought about but will probably add later
i'll probably come up with a better name, but let's be real that's unlikely
## Installation
### Step 1
To get this running, all you need to do is unzip this whole project (specifically the folders and the .ps1 file) and put it into your desired directory. 
by default, it is set to `$HOME/shell` 
(use your command terminal to find where $HOME is on your system)
### Step 2
Next, you will need to configure your PowerShell profile. to do this, open up your terminal and type in `notepad $PROFILE`
once you're here, all you need to do is copy paste these in:
``` txt
Import-Module PsIni -ErrorAction SilentlyContinue
. "$HOME\shell\shell.ps1"
```
and that's it! it should be prepared the next time you open up PowerShell
### Step 3
Finally, you want to install the required dependencies. you may have notices an error comes up when you open up PowerShell - that's okay!
i already wrote a command that goes through each dependency you need. just type in `shell dependencies` and it will scan through the entire list to see if you have the (one singular) dependencies you need for the project to function.

i will be making an installer later, dw about it
## Contribution
i mean, this is private rn but i don't really mind if anyone else wants to use or modify this
## Commands
### shell
Commands:
	ps1
opens the project file with VSCode if it is installed
	directory
shows the location of your project.
use -open to open this in your file explorer
	globals
displays all global variables
	preferences
displays all currently set preferences
	dependencies
checks to see if all dependencies are present
### initialise
resets the screen. equivalent to Clear-Host, but it resets all global variables, draws your selected banner, and chooses a greeting.
Mainly used for debugging the GOD DAMN .INI FILE AUGHH
### banner
draws your currently selected banner if you have one present
Commands:
	 edit 
 Opens your current banner in your default .txt editor
	 add 
Creates a new banner. enter a name, and use -open if you want to edit it after creation
	 remove 
Deletes a banner
	 list 
Shows all of your available banners
	 set 
Changes your selected default banner
	view
Lets you see a banner
	 paths 
Shows directory paths for debugging
### greet
Displays a random greeting (may give an option to switch between random and a selected one)
as of right now, there is no possible way to edit your greetings without opening up the .ps1 file
	list
shows all available greetings
