include Homebrew.make

TOPLEVEL := $(shell git rev-parse --show-toplevel)

SYMLINK_FILES = .vimrc .zshrc .zshenv .tmux.conf .gitconfig .ackrc .vim .zsh .config/fish bin 
SYMLINKS = $(foreach file,$(SYMLINK_FILES),$(HOME)/$(file))

$(HOME)/%: %
	ln -svf $(TOPLEVEL)/$< $(@)

$(HOME)/.gitignore:
	ln -svf $(TOPLEVEL)/gitignore $(HOME)/.gitignore

symlink: $(SYMLINKS) $(HOME)/.gitignore

all: symlink