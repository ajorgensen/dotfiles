#!/usr/bin/env ruby

INSTALL_DIRECTORY = File.expand_path("~")

def symlink(src, dest)
  dest = "#{INSTALL_DIRECTORY}/.#{dest}"
  src = File.expand_path("./#{src}")

  if File.exists?(dest)
    if File.symlink?(dest)
      puts "unlinking #{dest}"
      File.unlink(dest)
    else
      puts "#{dest} exists and is not a symlink"
      return
    end
  end

  puts "symlinking #{src} -> #{INSTALL_DIRECTORY}/.#{dest}"
  File.symlink(src, dest)
end

dotfiles = {
  "zshrc" => "zshrc",
  "zsh" => "zsh",
  "config/fish" => "config/fish",
  "gitignore" => "gitignore",
  "gitconfig" => "gitconfig",
  "vim" => "vim",
  "vimrc" => "vimrc",
  "tmux.conf" => "tmux.conf",
}

platform = ARGV[0]

if platform == "osx"
  puts "Configuring for osx"
elsif platform == "linux"
  puts "Configuring for linux"

  linux_dotfiles = { "i3" => "i3" }

  dotfiles.merge!(linux_dotfiles)
end

dotfiles.each do |src, destination|
  symlink(src, destination)

  puts ""
end
