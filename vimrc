set shell=bash

" ========================================================================
" NeoBundle stuff
" ========================================================================
if has('vim_starting')
 set nocompatible               " Be iMproved

 " Required:
 set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My bundles
NeoBundle 'ervandew/supertab'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'arecarn/crunch.vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'stjernstrom/vim-ruby-run'
NeoBundle 'rorymckinley/vim-symbols-strings'
"NeoBundle 'tomtom/tcomment_vim'
"NeoBundle 'tpope/vim-bundler'
NeoBundle 'tpope/vim-endwise'
"NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-surround'
NeoBundle 'flazz/vim-colorschemes'
"NeoBundle 'tpope/vim-rails'
"NeoBundle 'tpope/vim-rake'
"NeoBundle 'tpope/vim-unimpaired'
"NeoBundle 'tpope/vim-commentary'
"NeoBundle 'tpope/vim-surround'
NeoBundle 'vim-ruby/vim-ruby'
"NeoBundle 'elixir-lang/vim-elixir'
"NeoBundle 'leshill/vim-json'
"NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'terryma/vim-multiple-cursors'
"NeoBundle 'Gundo'
NeoBundle 'ctrlp.vim'
"NeoBundle 'vim-scripts/matchit.zip'
"NeoBundle "MarcWeber/vim-addon-mw-utils"
"NeoBundle "tomtom/tlib_vim"
NeoBundle "SirVer/ultisnips"
"NeoBundle 'honza/vim-snippets'
"NeoBundle "vim-scripts/javacomplete"
NeoBundle 'mileszs/ack.vim'
"NeoBundle 'tpope/vim-markdown'
"NeoBundle 'ecomba/vim-ruby-refactoring'
"NeoBundle 'skwp/greplace.vim'
NeoBundle 'roman/golden-ratio'
"NeoBundle 'suan/vim-instant-markdown'
"NeoBundle 'majutsushi/tagbar'
"NeoBundle 'gorkunov/smartgf.vim'
"NeoBundle 'tpope/vim-ragtag'
"NeoBundle 'tpope/vim-vinegar'
"NeoBundle 'rizzatti/dash.vim'
"NeoBundle 'xolox/vim-misc'
"NeoBundle 'christoomey/vim-tmux-runner'
"NeoBundle 'slim-template/vim-slim'
NeoBundle 'bling/vim-airline'
NeoBundle 'derekwyatt/vim-scala'

" nelstrom's plugin depends on kana's
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'nelstrom/vim-textobj-rubyblock'

" Clojure
"NeoBundle 'tpope/vim-fireplace'
"NeoBundle 'tpope/vim-classpath'
"NeoBundle 'guns/vim-clojure-static'

" Colors
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'altercation/vim-colors-solarized'

NeoBundleCheck
call neobundle#end()

" ========================================================================
" General Config
" ========================================================================
syntax on
filetype plugin indent on
autocmd FileType ruby compiler ruby

set nocompatible
"set clipboard=unnamed
let mapleader=","

set iskeyword+=-

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
set expandtab " turns spaces into tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set laststatus=2
set showmatch
set incsearch " search while typing
set hlsearch " highlight search matches
set undofile
set undodir=~/.vimundo/
" make searches case-sensitive only if they contain upper-case characters
"set ignorecase smartcase
set smarttab
set ignorecase
" set cursorline " highlight current line
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
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backspace=indent,eol,start
set showcmd
set wildmenu " make tab completion for files/buffers act like bash
set wildmode=full
hi clear SignColumn
hi SpellBad cterm=underline
set lazyredraw
set wrap
set linebreak

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

" ========================================================================
" Mappings
" ========================================================================
noremap <Leader>w :w<CR>
noremap <Leader>q :q<cr>
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P
" nmap <Leader><Leader> V
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
noremap ; :
noremap <C-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

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
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
let g:ctrlp_use_caching = 0

" ========================================================================
" Snipmate Config
" ========================================================================
" let g:snipMate = {} 
" let g:snipMate.scope_aliases = {} 
" let g:snipMate.scope_aliases['ruby']  = 'ruby,ruby-rails'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CTags CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set the tag file search order
nmap <F8> :TagbarToggle<CR>
nmap <F7> :UpdateTags<CR>
nmap <F6> :HighlightTags<CR>
let g:CoffeeAutoTagFile='./.tags'
let g:easytags_file = './.tags'
let g:easytags_auto_update = 0
let g:easytags_async = 1
set tags=./.tags
set complete=.,w,b,u,t,i 



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable " enable synatx processing
set t_Co=256 " 256 colors by default
colorscheme candyman

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
command! -bar -bang Q quit<bang>
command! W w
noremap Q <Nop>

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

nmap oo o<Esc>k
nmap OO O<Esc>j

cnoremap <C-p> <Up> 
cnoremap <C-n> <Down>

nnoremap <leader><space> :nohlsearch<CR> " turn off search highlight
inoremap jk <esc> " jk is escape

nnoremap <leader>u :GundoToggle<CR>         " toggle gundo

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

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

noremap <leader>f :CtrlP<cr>
nmap <c-g> :CtrlP<cr><C-\>w

map gr :execute " grep! -srnw --binary-files=without-match --exclude-dir=tmp --exclude-dir=.git --exclude-dir=log --exclude-dir=test --exclude-dir=spec --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
map gt :execute " grep! -srnw --binary-files=without-match --exclude-dir=.git --exclude-dir=log --exclude-dir=tags . -e " . expand("<cword>") . " " <bar> cwindow<CR>
map gG :execute " grep! -srnw --binary-files=without-match --exclude-dir=tmp --exclude-dir=.git --exclude-dir=tags ~/.rbenv/versions/$RBENV_VERSION/lib/ruby/gems/1.9.1 -e " . expand("<cword>") . " " <bar> cwindow<CR>

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

nnoremap <C-t> :call NumberToggle()<cr>
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
