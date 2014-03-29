# Andrew Jorgensen Dot Files

Yay config files.

## Installation

Run the following commands in your terminal. It will prompt you before it does anything destructive. Check out the [Rakefile](https://github.com/ajorgensen/dotfiles/blob/master/Rakefile) to see exactly what it does.

```terminal
git clone https://github.com/ajorgensen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
rake install
```

If you only want to install certain dotfile you can pass in a comma separated run_list by doing:

```terminal
rake install run_list="vim,vimrc,config/fish"
```

To uninstall, note this can also take a run_list like install:

```terminal
rake uninstall
```


