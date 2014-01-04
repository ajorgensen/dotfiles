set nocompatible
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-fireplace'
Bundle "guns/vim-clojure-static"
Bundle 'Auto-Pairs'
Bundle 'jpalardy/vim-slime'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'leshill/vim-json'
Bundle 'airblade/vim-gitgutter'
Bundle 'vim-ruby/vim-ruby'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'ctrlp.vim'
Bundle 'Gundo'
Bundle 'SuperTab'
Bundle 'github-theme'
Bundle 'hughbien/md-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/webapi-vim'
Bundle 'ZenCoding.vim'
Bundle 'Better-Javascript-Indentation'
Bundle 'junegunn/vim-easy-align'
Bundle 'arecarn/crunch'
Bundle 'Tabular'
Bundle 'suan/vim-instant-markdown'

" NEW STUFF
Bundle 'scrooloose/nerdcommenter'
Bundle 'majutsushi/tagbar'
Bundle 'troydm/easybuffer.vim'
Bundle 'mileszs/ack.vim'
Bundle 'Gundo'

filetype plugin indent on
syntax on

au BufNewFile,BufRead *.md set ft=md
au BufRead,BufNewFile *.go set ft=go

set shell=bash

" Turn off auto comment insterting
set formatoptions-=ro

nnoremap <leader>` :sp ~/Documents/notes/programming_notes.txt<cr>

nnoremap <silent> + :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 2/3)<CR>

let g:slime_target = "tmux"

augroup myvimrc
  au!
  au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" ===================
" AutoPairs settings
" ===================
let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}

" ===================
" VimClojure settings
" ===================
let vimclojure#HighlightBuiltins = 1 " Highlight Clojure's builtins
let vimclojure#ParenRainbow = 1 " Rainbox parens

let g:instant_markdown_autostart = 0

" =============
" Clojure Stuff
" =============
let g:clojure_align_multiline_strings = 0
let g:clojure_fuzzy_indent = 1
let g:clojure_fuzzy_indent_patterns = "with.*,def.*,let.*,send.*,fact,facts"

" =============
" ctrlp configs 
" =============
let g:ctrlp_max_files = 0
let g:ctrlp_working_path_mode = 0
set wildignore+=*.class

" =============
" Ruby Stuff
" =============
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=78
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass 

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Indent p tags
  " autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  " Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off

  " Leave the return key alone when in command line windows, since it's used
  " to run commands there.
  autocmd! CmdwinEnter * :unmap <cr>
  autocmd! CmdwinLeave * :call MapCR()
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TAGLIST CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_WinWidth = 50
map <F4> :TlistToggle<cr>
map <F8> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
nmap <F9> :TagbarToggle<CR>
set tags+=gems.tags

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable
set t_Co=256
" colorscheme wombat256mod
colorscheme molokai

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set nobackup
set nowritebackup
set noswapfile
set history=1000
set ruler
set noerrorbells
set splitright
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
set cmdheight=2
set switchbuf=useopen
set numberwidth=5
" set showtabline=2
set winwidth=79
" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" make tab completion for files/buffers act like bash
set wildmenu
set wildmode=full
let mapleader=","
hi clear SignColumn

" Highlighting at 80 and 120 characters
let &colorcolumn=join(range(81,999),",")
let &colorcolumn="80,".join(range(120,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=78
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass 

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Indent p tags
  " autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  " Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off

  " Leave the return key alone when in command line windows, since it's used
  " to run commands there.
  autocmd! CmdwinEnter * :unmap <cr>
  autocmd! CmdwinLeave * :call MapCR()
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC KEY MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>y "+y
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
noremap <c-s> <esc>:w<cr>
command! Q q
command! W w

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

nmap oo o<Esc>k
nmap OO O<Esc>j

cnoremap <C-p> <Up> 
cnoremap <C-n> <Down>

"noremap <C-l> :nohl<CR>

:set vb

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPEN FILES IN DIRECTORY OF CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>n :call RenameFile()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAPS TO JUMP TO SPECIFIC COMMAND-T TARGETS AND FILES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>gr :topleft :split config/routes.rb<cr>
function! ShowRoutes()
  " Requires 'scratch' plugin
  :topleft 100 :split __Routes__
  " Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
  " Delete everything
  :normal 1GdG
  " Put routes output in buffer
  :0r! rake -s routes
  " Size window to number of lines (1 plus rake output length)
  :exec ":normal " . line("$") . "_ "
  " Move cursor to bottom
  :normal 1GG
  " Delete empty trailing line
  :normal dd
endfunction
noremap <leader>f :CtrlP<cr>

"nnoremap gr :grep <cword> . --exclude-dir=log -R | copen<CR>
"nnoremap gG :grep <cword> ~/.rbenv/versions/$RBENV_VERSION/lib/ruby/gems/1.9.1/**/*.rb -R | copen<CR>
map gr :execute " grep! -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=log --exclude-dir=test --exclude-dir=spec --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
map gt :execute " grep! -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=log --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
map gG :execute " grep! -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=tags ~/.rbenv/versions/$RBENV_VERSION/lib/ruby/gems/1.9.1 -e " . expand("<cword>") . " " <bar> cwindow<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':sp ' . new_file
endfunction
function! AlternateForCurrentFile()
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1
  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.rb$', '_test.rb', '')
    let new_file = 'test/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    end
  endif
  return new_file
endfunction
nnoremap <leader>. :call OpenTestAlternate()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"map <leader>t :call RunTestFile()<cr>
"map <leader>T :call RunNearestTest()<cr>
"map <leader>a :call RunTests('')<cr>
"map <leader>c :w\|:!script/features<cr>
"map <leader>w :w\|:!script/features --profile wip<cr>

map <leader>z :wa\|:call RunPresetTest()<cr>
map <leader>Z :call SetTestFile()<cr>
map <leader>c :call UnsetTestFile()<cr>
map <leader>a :call OpenTestFile()<cr>

let g:rubytest_cmd_testcase = "ruby %p -n '/%c/'"

function! OpenTestFile()
  if isdirectory("./spec")
    let matching_files = split(globpath('./spec/**', expand("%:t:r") . "_spec.rb"), "\n")
  else
    let matching_files = split(globpath('./test/**', expand("%:t:r") . "_test.rb"), "\n")
  endif

  if len(matching_files) == 1
    exec ":vsp " . matching_files[0]
  else
    for file in matching_files
      if !empty(matchstr(file, expand("%:h:t")))
        exec ":vsp " . file
        break
      endif
    endfor
  end
endfunction

let g:rubytest_cmd_testcase = "ruby %p -n '/%c/'"

function! RunPresetTest() 
    call SpinRunning()

    if exists("t:grb_test_file")
      if exists("t:spin_running")
        exec "!spin push " . t:grb_test_file 
      else
        if match(expand(t:grb_test_file), '\(_test.rb\)$') > 0
          exec "!bundle exec ruby " . t:grb_test_file 
        elseif match(expand(t:grb_test_file), '\(_spec.rb\)$') > 0
          exec "!bundle exec rspec " . t:grb_test_file 
        end
      endif
    else
      if isdirectory("./spec")
        if exists("t:spin_running")
          exec "!spin push spec"
        else
          exec "!bundle exec rspec"
        endif
      else
        exec "!bundle exec rake"
      endif
    end
  endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! SpinRunning()
  let l = system("ps aux | grep 'spin' | grep -v grep | wc -l | tr -d ' '")
  if l == 1
    let t:spin_running=1
  else
    if exists("t:spin_running")
      unlet t:spin_running
    endif
  endif
endfunction

function! UnsetTestFile() 
  if exists("t:grb_test_file")
    unlet t:grb_test_file 
  end
endfunction

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number . " -b")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Md5 COMMAND
" Show the MD5 of the current buffer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -range Md5 :echo system('echo '.shellescape(join(getline(<line1>, <line2>), '\n')) . '| md5')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" InsertTime COMMAND
" Insert the current time
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>

if has("autocmd")
  autocmd BufWritePre {*.rb,*.js,*.coffee,*.scss,*.haml,*.py,*.js,*.clj} :call <SID>CleanFile()
endif

function! <SID>CleanFile()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %!git stripspace
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function! <SID>StripBlankLinesAtEndOfFile()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")

    %s#\($\n\s*\)\+\%$##

    let @/=_s
    call cursor(l, c)
endfunction

set relativenumber
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set nonumber
    set relativenumber
  endif
endfunc

function! ToggleSpellchecker()
  if(&spell == 1)
    echo "Spell checker off"
    set nospell
  else
    echo "Spell checker on"
    set spell spelllang=en_us
  endif
endfunc

nnoremap <C-t> :call NumberToggle()<cr>
nnoremap <F3> :call ToggleSpellchecker()<cr>
nnoremap <F2> :RainbowParenthesesToggle<cr>

