set shell=bash

" ========================================================================
" Much plugin, such features
" mkdir -p ~/.vim/autoload
" curl -fLo ~/.vim/autoload/plug.vim \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
" ========================================================================
if has('nvim')
  call plug#begin('~/.config/nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

" General
if has('nvim')
  Plug 'benekastah/neomake'
  autocmd! BufWritePost * Neomake
endif

Plug 'Shougo/deoplete.nvim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'SirVer/ultisnips'
Plug 'mileszs/ack.vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'rking/ag.vim'
Plug 'roman/golden-ratio'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'altercation/vim-colors-solarized'
Plug 'terryma/vim-multiple-cursors'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

Plug 'sheerun/vim-polyglot'

" Ruby
"Plug 'nelstrom/vim-textobj-rubyblock', { 'for': [ 'rb' ] }

" Elixir
" Plug 'elixir-lang/vim-elixir', { 'for': [ 'ex', 'exs' ] }

" Markdown
Plug 'shime/vim-livedown', { 'for': [ 'md' ] }

" Javascript
" Plug 'pangloss/vim-javascript', { 'for': [ 'js' ] }
" Plug 'kchmck/vim-coffee-script', { 'for': [ 'coffee' ] }

call plug#end()

" Deoplete
let g:deoplete#enable_at_startup=1

" ========================================================================
" General Config
" ========================================================================
" Enable filetype plugins
filetype plugin indent on

" How many lines of history vim has to remember
set history=1000

" Auto read a when a file is changed
set autoread

" Make vim not comptabile with vi
set nocompatible

" Makes searching for css tokens easier
set iskeyword+=-

" Allow unsaved background buffers and remember marks/undo for them
set hidden

" Don't backup the current file before writing
set nobackup
set nowritebackup

" Turn off swap files
set noswapfile

" Turn off the annoying bell when an error happens
set noerrorbells

" Put the new split to the right of the current one
set splitright

" Search while typing
set incsearch

" Dont ignore case if the search has an uppercase character
set smartcase

" Highlight search matches
set hlsearch

" Always show the status line
set laststatus=2

" Persist undo history across session
set undofile
set undodir=~/.vimundo/

" Ignore case in searches
set ignorecase

" Set the height of the command box
set cmdheight=2

" Switch between open buffers
set switchbuf=useopen

" Minimum width for line numbers
set numberwidth=5

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

" Keep more context when scrolling off the end of a buffer
set scrolloff=3

set backspace=indent,eol,start
set showcmd

" Make tab completion for files/buffers act like bash
set wildmenu 
set wildmode=full

" Dont redraw when executing macros etc until they are done
set lazyredraw
set ttyfast
set synmaxcol=128

" ========================================================================
" Formatting
" ========================================================================
" Turns spaces into tabs
set expandtab 

" 1 tab == 2 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2

set cursorline

set showmatch

" Auto indent based on the previous line
set autoindent

" Insert blanks when tab is in front of a line
set smarttab

" Wrap lines to fit on the screen
set wrap
set linebreak

" Custom status line
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" ========================================================================
" Mappings
" ========================================================================
let mapleader=","
let g:mapleader=","
"let mapleader = " "
"let g:mapleader = " "

" Faster saving
noremap <Leader>w :w<CR>

" Fast quiting
noremap <Leader>q :q<cr>

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P
noremap ; :
noremap <C-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

map <leader>y "+y
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
inoremap ii <ESC>
noremap <c-s> <esc>:w<cr>
command! Q q
command! -bar -bang Q quit<bang>
command! W w
noremap Q <Nop>

" Move around splits with <c-hjkl>
" See: https://github.com/neovim/neovim/issues/2048
if has('nvim')
  nmap <BS> <C-W>h
endif
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

inoremap jk <ESC>

nmap oo o<Esc>k
nmap OO O<Esc>j

cnoremap <C-p> <Up> 
cnoremap <C-n> <Down>

nnoremap <leader><space> :nohlsearch<CR> " turn off search highlight
inoremap jk <esc> " jk is escape

nnoremap H 0
nnoremap L $

nnoremap ; :

nnoremap <leader>u :GundoToggle<CR>         " toggle gundo

" Arrow keys are unacceptable
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

let g:xmpfilter_cmd = "seeing_is_believing"

autocmd FileType ruby nmap <buffer> <leader>rm <Plug>(seeing_is_believing-mark)
autocmd FileType ruby xmap <buffer> <leader>rm <Plug>(seeing_is_believing-mark)
autocmd FileType ruby imap <buffer> <leader>rm <Plug>(seeing_is_believing-mark)

autocmd FileType ruby nmap <buffer> <leader>rc <Plug>(seeing_is_believing-clean)
autocmd FileType ruby xmap <buffer> <leader>rc <Plug>(seeing_is_believing-clean)
autocmd FileType ruby imap <buffer> <leader>rc <Plug>(seeing_is_believing-clean)

" xmpfilter compatible
autocmd FileType ruby nmap <buffer> <leader>rr <Plug>(seeing_is_believing-run_-x)
autocmd FileType ruby xmap <buffer> <leader>rr <Plug>(seeing_is_believing-run_-x)
autocmd FileType ruby imap <buffer> <leader>rr <Plug>(seeing_is_believing-run_-x)

" auto insert mark at appropriate spot.
autocmd FileType ruby nmap <buffer> <F5> <Plug>(seeing_is_believing-run)
autocmd FileType ruby xmap <buffer> <F5> <Plug>(seeing_is_believing-run)
autocmd FileType ruby imap <buffer> <F5> <Plug>(seeing_is_believing-run)


" auto wrap git commit messages
autocmd Filetype gitcommit setlocal spell textwidth=72

" Toggle the nerd trees
map <C-t> :NERDTreeToggle<CR>
let g:NERDTreeWinSize = 40 

" Open In Github
map <leader>gh :OpenGithubFile<cr>
map <leader>hg :<,'>OpenGithubFile<cr>

" ========================================================================
" Color and Fonts
" ========================================================================
syntax on
syntax enable " enable synatx processing

set t_Co=256 " 256 colors by default
" colorscheme candyman
if !has("gui_running")
    let g:solarized_termtrans=1
    let g:solarized_termcolors=256
endif"
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
set background=dark
colorscheme solarized

if !has('nvim')
  set encoding=utf8
endif

" Set highlighting format
hi clear SignColumn
hi SpellBad cterm=underline

""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd FileType ruby compiler ruby

au BufNewFile,BufRead *.md set ft=md
au BufRead,BufNewFile *.go set ft=go
au BufRead,BufNewFile *.coffee set ft=coffee

let g:slime_target = "tmux"
set virtualedit=onemore "Needed so vim-scala doesn't shit the bed

" Open QuickFix window after git grep in vim-fugitive
autocmd QuickFixCmdPost *grep* cwindow

augroup myvimrc
  au!
  au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" ===================
" VimClojure settings
" =================== 
" Highlight Clojure's builtins
let vimclojure#HighlightBuiltins = 1

 " Rainbox parens
let vimclojure#ParenRainbow = 1
let g:instant_markdown_autostart = 0

" =============
" Clojure Stuff
" =============
let g:clojure_align_multiline_strings = 0
let g:clojure_fuzzy_indent = 1
let g:clojure_fuzzy_indent_patterns = "with.*,def.*,let.*,send.*,fact,facts"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CTags config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set the tag file search order
"nmap <F8> :TagbarToggle<CR>
"nmap <F7> :UpdateTags<CR>
"nmap <F6> :HighlightTags<CR>
let g:CoffeeAutoTagFile='./.tags'
let g:easytags_file = './.tags'
let g:easytags_auto_update = 0
let g:easytags_async = 1
set tags=./.tags
set complete=.,w,b,u,t,i 

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
"inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPEN FILES IN DIRECTORY OF CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"cnoremap %% <C-R>=expand('%:h').'/'<cr>
"map <leader>e :edit %%
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
" Git add all and commit
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GitAddAllAndCommit()
  let message = input('Commit message: ')
  if message != ''
    exec ':wa'
    exec ':silent !git add --all'
    exec ':silent !git commit -m "' . message . '"'
    redraw!
  endif
endfunction
map <leader>sc :call GitAddAllAndCommit()<cr>

noremap <leader>f :FZF<cr>

"map gr :execute " grep! -srnw --binary-files=without-match --exclude-dir=tmp --exclude-dir=.git --exclude-dir=log --exclude-dir=test --exclude-dir=spec --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
"map gt :execute " grep! -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=log --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
"map gG :execute " grep! -srnw --binary-files=without-match --exclude-dir=tmp --exclude-dir=.git --exclude-dir=tags ~/.rbenv/versions/$RBENV_VERSION/lib/ruby/gems/1.9.1 -e " . expand("<cword>") . " " <bar> cwindow<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>Z :call SetTestFile()<cr>
map <leader>c :call UnsetTestFile()<cr>
map <leader>a :call OpenTestFile()<cr>
map <leader>stp :exec '!mvn exec:java -Dexec.mainClass="' . expand("%:t:r") . '"'<cr>

augroup filetype_java
    autocmd!
    autocmd FileType java map <leader>z :wa\|:call RunPresetJavaTest()<cr>
    autocmd FileType ruby map <leader>z :wa\|:call RunPresetRubySpec()<cr>
augroup END

let g:rubytest_cmd_testcase = "ruby %p -n '/%c/'"

function! OpenTestFile()
  let matching_files = split(globpath('./spec/**', expand("%:t:r") .  "_spec.rb"), "\n")
  let matching_files = matching_files + split(globpath('./test/**', expand("%:t:r") . "_test.*"), "\n")
  let matching_files = matching_files + split(globpath('./src/test/**', expand("%:t:r") . "*Test.java"), "\n")

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

function! RunPresetJavaTest()
  if exists("t:grb_test_file")
    exec "!mvn -Dtest=" . fnamemodify(t:grb_test_file, ':t:r') . " test"
  endif
endfunction

let g:rubytest_cmd_testcase = "ruby %p -n '/%c/'"
function! RunPresetRubySpec() 
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
  let l = system("ps aux | grep 'spin serve' | grep -v grep | wc -l | tr -d ' '")
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

if has("autocmd")
  autocmd BufWritePre {*.rb,*.js,*.coffee,*.scss,*.haml,*.py,*.js,*.clj} :call <SID>CleanFile()
endif

function! <SID>CleanFile()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let [l,c] = [line("."),col(".")]

    " Do the business:
    " %!git strip space
    silent! %s/\s\+$//e
    silent! %s#\($\n\s*\)\+\%$##

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
set nu

function! ToggleSpellchecker()
  if(&spell == 1)
    echo "Spell checker off"
    set nospell
  else
    echo "Spell checker on"
    set spell spelllang=en_us
  endif
endfunc

nnoremap <F3> :call ToggleSpellchecker()<cr>

function! FixLastSpellingError()
  set spell spelllang=en_us
  normal! mm[s1z=`m
endfunction
nnoremap <leader>sp :call FixLastSpellingError()<cr>

augroup myfiletypes
  " Clear old autocmds in group
  autocmd!
  " autoindent with two spaces, always expand tabs
  autocmd FileType ruby,eruby,yaml setlocal ai sw=2 sts=2 et
  autocmd FileType ruby,eruby,yaml setlocal path+=lib
  autocmd FileType ruby,eruby,yaml setlocal colorcolumn=80
  autocmd FileType java setlocal sw=4
augroup END

function! FormatJson()
  call %!python -m json.tool
endfunction

" Highlighting at 81st column
highlight ColorColumn ctermbg=235
set colorcolumn=80

" Make Y behave like other capitals
map Y y$

" Ack Motions
nnoremap <silent> \a :set opfunc=<SID>AckMotion<CR>g@
xnoremap <silent> \a :<C-U>call <SID>AckMotion(visualmode())<CR>
 
function! s:CopyMotionForType(type)
    if a:type ==# 'v'
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    endif
endfunction
 
function! s:AckMotion(type) abort
    let reg_save = @@
 
    call s:CopyMotionForType(a:type)
 
    execute "normal! :Ack! --literal " . shellescape(@@) . "\<cr>"
 
    let @@ = reg_save
endfunction

" Use the silver searcher (ag) with ack.vim
let g:ackprg = 'ag --nogroup --nocolor --column'

" Inline the output of an external command and strip out newlines
function! InlineCommand()
    let l:cmd = input('Command: ')
    let l:output = system(l:cmd)
    let l:output = substitute(l:output, '[\r\n]*$', '', '')
    execute 'normal i' . l:output
endfunction

nmap <silent> \e :call InlineCommand()<CR>
command! FormatJSON %!python -m json.tool


""""""""""""""
" Geeknote
""""""""""""""
noremap <F8> :Geeknote<cr>

""""""""""""""
" Markdown TOC
""""""""""""""
let g:mdtoc_run_on_save = 1

if filereadable(glob(".local.vim")) 
    source .local.vim
endif

""""""""""""""
" Markdown TOC
""""""""""""""
let g:yankstack_map_keys = 0
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" When open a new file remember the cursor position of the last editing
if has("autocmd")
  let blacklist = ['gitcommit']
  if index(blacklist, &ft) < 0
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost * if line("'\"") | exe "'\"" | endif
  endif
endif


""""""""""""""
" Ultisnips
""""""""""""""
let g:UltiSnipsExpandTrigger="<c-k>"
let g:UltiSnipsJumpForwardTrigger="<c-k>"
let g:UltiSnipsJumpBackwardTrigger="<s-c-j>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]