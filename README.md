# shell thing
a 'lil powershell module manager sandbox thingy i made

This provides:
 - Tools for creating custom modules
 - Editable custom profiles with automatically loading modules
 - Persistent profile preferences
 - Additional powershell helpers i wrote myself :rizz-emoji:
 - Other modules for fun

All modules live in `modules/*.psm1`
All data is stored in `data/<module name>`
All preferences and helpers are stored in `data/shelldata`

## Installation
First, download this repo (you need shell.ps1 and everything inside `data/shellmodules`)
Then, add it to your `$PROFILE` to make it run on startup
Open your terminal a couple times (it can freak out on its first boot)
And you're done 🎉

## Development
To create a new module, just drop it into `modules/`. it will load automatically when the terminal resets
Want to use `data/`? the path to `shell.ps1` is saved in one global variable: `$global:projectDir`. everything is relative to that path
Or, just use whatever structure you want. i'm not your boss lmao

## Notes
Not all of the modules provided here are reliable.
`osu.psm1` for example has a bug that causes a PsIni error for every single osu beatmap diff you have
(assuming you're an osu player)

Modules that do work reliably are here...
##### Genuinely helpful ones:
 - **navvi.psm1**
 - **viewitem.psm1** (wezterm exclusive rn)
 - **ytdownload.psm1**

##### Customisation:
 - **banner.psm1**
 - **greet.psm1**

##### For fun:
 - **copium.psm1**
 - **freakify.psm1**

##### Experimental:
 - **quicktrust.psm1**
 - **steam.psm1**
 - **sybau.psm1**

## Later...
Modules will be downloadable online with a helper tool.
idk what else honestly
