# shell thing
so it's on linux now

This provides:
 - Tools for creating custom modules
 - Editable custom profiles with automatically loading modules
 - Persistent profile preferences
 - Additional powershell helpers i wrote myself :rizz-emoji:
 - Other modules for fun

All modules live in `modules/*.zsh`

All data is stored in `data/<module name>`

All preferences and helpers are stored in `data/shelldata`

## Installation
Zsh is a dependency for this to function

First, download this repo

Then, source `shell.sh` in your `~/.zshrc` to make it run on startup

Open your terminal a couple times (it can freak out on its first boot)

And you're done 🎉

## Development
To create a new module, just drop it into `modules/`. it will load automatically when the terminal resets

Want to use `data/`? the path to `shell.sh` is saved in one global variable: `SHELL_ROOT`. everything is relative to that path

Or, just use whatever structure you want. i'm not your boss lmao

## Notes
i literally just started this, chill dawg

Modules that do work reliably are here...
##### working:
 - **greet.zsh**

##### not working:
 - **copium.psm1**
 - **freakify.psm1**
 - **close.psm1**
 - **banner.psm1**
 - **navvi.psm1**
 - **viewitem.psm1**
 - **ytdownload.psm1**
 - **measuresize.psm1**
 - **quicktrust.psm1**
 - **steam.psm1**
 - **sybau.psm1**

## Later...
More modules later maybe, idk

# 600 pages of grown men meowing at each other
WHY IS THIS LINE HERE
