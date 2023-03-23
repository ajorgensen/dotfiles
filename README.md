# dotfiles

========

## Install Brew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Clone this Repo

```
git clone git@github.com:ajorgensen/dotfiles.git ~/.dotfiles
```

## Init submodules

```
git submodule init
git submodule update
```

## Install Packages

```
brew bundle
```

### Symlink dotfiles

```
make stow
```
