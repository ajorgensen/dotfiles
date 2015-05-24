# Andrew Jorgensen Dot Files

Yay config files. Maybe someday I'll find some time to write a proper readme.

## Basic Usage
This will install all the dotfiles with the suffix `.symlink` into your home directory. It will ask before doing anything desctrucive.
```terminal
bash ./script/bootstrap
```

To install the platform specific packages you can do the following
```terminal
bash ./script/install_packages
```

You can also pass in a flag to be asked before each package is installed
```terminal
ASK=true bash ./script/install_packages
```
