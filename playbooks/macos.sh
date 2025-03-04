#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

## Software Update

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Automatically download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

## NSGlobalDomain

# Show all filename extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable subpixel font rendering on non-Apple LCDs.
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Disable press-and-hold for keys in favor of key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a fast KeyRepeat rate. We prefer 1 (15ms). The default minimum is 2 (30ms). May require reboot.
defaults write NSGlobalDomain KeyRepeat -int 1

# Set a fast initial key repeat. We prefer 4 (60ms). The default minimum is 15 (225ms). May require reboot.
defaults write NSGlobalDomain InitialKeyRepeat -int 4

# Disable "Natural" scrolling for trackpad. May require reboot.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Disable "Natural" scrolling for mouse. May require reboot.
defaults write NSGlobalDomain com.apple.mouse.scaling -float -1
defaults write NSGlobalDomain AppleInterfaceStyle Dark

## NSGlobalDomain NS*

# Disable typing automatic capitalization.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable typingautomatic period substition a.k.a. "smart stops".
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -int 0

# Disable typing automatic dash substitution e.g. "smart dashes".
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable typing automatic quote substitution a.k.a. "smart quotes".
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable typing automatic spelling correction a.k.a. "auto-correct".
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Expand save panel by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Speed up window resize time.
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

## Finder

# Show all files.
defaults write com.apple.finder AppleShowAllFiles YES

# Show all extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Always open everything in Finder's list view
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Allow selection of text in quicklook windows.
defaults write com.apple.finder QLEnableTextSelection -bool true

# Enable quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Show status bar.
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar.
defaults write com.apple.finder ShowPathbar -bool true

# Disable warning when the user does empty trash.
defaults write com.apple.finder WarnOnEmptyTrash -bool false

## Dock

# Move Dock to the left side of the screen
#defaults write com.apple.dock "orientation" -string "left" && killall Dock

# Make Dock icons of hidden applications translucent.
defaults write com.apple.dock showhidden -bool true

# Enable iTunes track notifications in the Dock.
defaults write com.apple.dock itunes-notifications -bool true

# Show indicator lights for open applications in the Dock.
defaults write com.apple.dock show-process-indicators -bool true

# Remove the auto-hiding Dock delay.
defaults write com.apple.Dock autohide-delay -float 0

# Automatically hide and show the Dock.
defaults write com.apple.dock autohide -bool true

# Disable expose animation.
defaults write com.apple.dock expose-animation-duration -float 0

## Network Browser

# Use AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

## Terminal

# Only use UTF-8 in Terminal.app.
defaults write com.apple.terminal StringEncodings -array 4

## Desktop Services

# Avoid creating .DS_Store files on network volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

## Bluetooth

# Set Bluetooth headset higher bitrate.
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

## Press And Hold

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Hide desktop icons
defaults write com.apple.finder CreateDesktop false

## Flags

# Show the ~/Library folder.
chflags nohidden ~/Library

## Finally

# Kill affected applications.
for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
