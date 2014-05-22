require 'rake'
require 'erb'
require 'pry'

desc "Installs the dotfiles"
task :install do
  overwrite_all = false
  skip_all = false

  to_install.each do |src, dest|
     next puts "File #{src} does not exist" if !File.exists? src

     if !skip_all
       if File.exists? dest
         overwrite = false
         skip = false

         if !overwrite_all
           puts "#{dest} already exists. What do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all?"
           action = STDIN.gets.chomp

           case action
           when "s"; skip = true
           when "S"; skip_all = true
           when "o"; overwrite = true
           when "O"; overwrite_all = true
           end
         end

         if overwrite || overwrite_all
           `rm -rf #{dest}` 
         end

         if !skip && !skip_all
           if sub_tree?(file)
             create_folder dest
           end

           link_file(src, dest)
         else
           puts "skipped #{src}"
         end
       else
         if sub_tree?(file)
           create_folder dest
         end

         link_file(src, dest)
       end
      else
        puts "skipped #{src}"
     end
  end
end

desc "Uninstalls the dotfiles"
task :uninstall do
  home_path = ENV['HOME']

  to_install.each do |file|
     dest = "#{home_path}/.#{file}"

     unlink_file(dest)
  end
end

desc "Installs NeoBundle for vim extention management"
task :install_neobundle do
  if !File.directory? "#{ENV['HOME']}/.vim"
    puts "Please install vim first"
    exit
  end

  system %Q{mkdir -p #{ENV['HOME']}/.vim/bundle}
  system %Q{git clone https://github.com/Shougo/neobundle.vim #{ENV['HOME']}/.vim/bundle/neobundle.vim}
end

desc "Installs Rbenv and ruby build"
task :install_rbenv do
  system %Q{git clone https://github.com/sstephenson/rbenv.git #{ENV['HOME']}/.rbenv}
  system %Q{git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build}
end

def install_tmux
  system %Q{brew install tmux}
  system %Q{brew install reattach-to-user-namespace}
end

def to_install
  if ENV['run_list']
    files = ENV['run_list'].split(',').map(&:chomp)
  else
    files = Dir['*']
    files << "config/fish"
    files << "i3" if linux?
  end

  files -= %w(Rakefile config README.md)
  
  files_to_install = files.inject(Array.new) do |state, file|
    if file == "bin"
      bin_files.collect do |bin_file|
        src = "#{Dir.pwd}/#{bin_file}"
        dest = "/usr/local/bin/#{File.basename(bin_file)}"
        state << [src, dest]
      end
    elsif file.include?("bin")
      src = "#{Dir.pwd}/#{file}"
      dest = "/usr/local/bin/#{File.basename(file)}"
      state << [src, dest]
    else
      src = "#{Dir.pwd}/#{file}"
      dest = "#{ENV['HOME']}/.#{File.basename(file)}"
      state << [src, dest]
    end

    state
  end

  files_to_install
end

def bin_files
  Dir['bin/*']
end

def unlink_file(path)
  puts "unlinking #{path}"
  system %Q{unlink "#{path}"}
end

def link_file(src, dest)
  puts "linked #{src} #{dest}"
  system %Q{ln -s "#{src}" "#{dest}"}
end

def create_folder(path)
  puts "creating folder #{path}"
  system %Q{mkdir -p "#{path}"}
end

def sub_tree?(file)
  (file =~ /\//) != nil
end

def osx?
  RUBY_PLATFORM.include? "darwin"
end

def linux?
  RUBY_PLATFORM.include? "linux"
end
