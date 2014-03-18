require 'rake'
require 'erb'
require 'pry'

task :install do
  home_path = ENV['HOME']

  overwrite_all = false
  skip_all = false

  files = Dir['*'] - %w(Rakefile config i3 README.md)
  files << "config/fish"

  files.each do |file|
     src = "#{Dir.pwd}/#{file}"
     dest = "#{home_path}/.#{file}"

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
             create_folder "#{home_path}/.#{File.dirname(file)}"
           end

           link_file(src, dest)
         else
           puts "skipped #{src}"
         end
       else
         if sub_tree?(file)
           create_folder "#{home_path}/.#{File.dirname(file)}"
         end

         link_file(src, dest)
       end
      else
        puts "skipped #{src}"
     end
  end
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
  file =~ /\//
end

def osx?
  RUBY_PLATFORM.include? "darwin"
end

def linux?
  RUBY_PLATFORM.include? "linux"
end
