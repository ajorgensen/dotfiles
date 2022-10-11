require('telescope').setup{
  defaults = {
    file_ignore_patterns = { ".git/" },
  },
  pickers = {
    find_files = {
      disable_devicons = true
    },
  },
}
