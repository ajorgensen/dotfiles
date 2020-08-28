let mapleader=","

" remove all existing autocmds
autocmd!

" initialize plugins
call plug#begin('~/.vim/plugged')

" =======
" General
" =======
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'sirver/ultisnips'
Plug 'scrooloose/nerdcommenter'
Plug 'suan/vim-instant-markdown'
Plug 'janko-m/vim-test'
Plug 'mileszs/ack.vim'

" =====
" colors
" =====
Plug 'drewtempelmeyer/palenight.vim'

" =====
" tpope
" =====
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-dispatch'

" =========
" Languages
" =========
Plug 'w0rp/ale'
Plug 'vim-ruby/vim-ruby'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'fatih/vim-go'

" TypeScript highlighting/indent
Plug 'leafgarland/typescript-vim'

" TypeScript semantic support
Plug 'Quramy/tsuquyomi'

call plug#end()

" ====================
" Basic Editing Config
" ====================
set nocompatible
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
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
set cmdheight=1
set switchbuf=useopen
" Always show tab bar at the top
set showtabline=2
set winwidth=79
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" Don't make backups at all
set nobackup
set nowritebackup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
syntax enable
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" use emacs-style tab completion when selecting files, etc
set wildmode=longest,list
" make tab completion for files/buffers act like bash
set wildmenu
" Fix slow O inserts
:set timeout timeoutlen=1000 ttimeoutlen=100
" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1
" Modelines (comments that set vim options on a per-file basis)
set modeline
set modelines=3
" Turn folding off for real, hopefully
set foldmethod=manual
set nofoldenable
" Insert only one space when joining lines that contain sentence-terminating
" punctuation like `.`.
set nojoinspaces
" If a file is changed outside of vim, automatically reload it without asking
set autoread
" Use the old vim regex engine (version 1, as opposed to version 2, which was
" introduced in Vim 7.3.969). The Ruby syntax highlighting is significantly
" slower with the new regex engine.
set re=1
" Stop SQL language files from doing unholy things to the C-c key
let g:omni_sql_no_default_maps = 1
" Diffs are shown side-by-side not above/below
set diffopt=vertical
" Always show the sign column
set signcolumn=no
" Write swap files to disk and trigger CursorHold event faster (default is
" after 4000 ms of inactivity)
set updatetime=200
" Completion options.
"   menu: use a popup menu
"   preview: show more info in menu
set completeopt=menu,preview

" Switch between open buffers
set switchbuf=useopen
set dictionary+=/usr/share/dict/words

set nowrap
set number

" Highlighting at 121st column
highlight ColorColumn ctermbg=235
set colorcolumn=120

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAPPINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
imap jj <ESC>
nmap <leader>w :w<cr>
nmap <leader>x :x<cr>

" Use <leader>Esc to leave terminal mode
tnoremap <leader><Esc> <C-\><C-n>
tnoremap <leader>jj <C-\><C-n>

" Easy buffer navigation
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <C-X> :bdelete<CR>
noremap <leader>b :Buffers<CR>
nnoremap <F2> :buffers<CR>:buffer<Space>

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
  autocmd FileType ruby,haml,eruby,yaml,html,sass,cucumber set ai sw=2 sts=2 et
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

  " *.md is markdown
  autocmd! BufNewFile,BufRead *.md setlocal ft=

  " indent slim two spaces, not four
  autocmd! FileType slim set sw=2 sts=2 et

  " javascript
  autocmd! FileType javascript set sw=2 sts=2 expandtab

  " Expand tabs in Go. Was gofmt raised in a barn?!
  autocmd! FileType go set sw=4 sts=4 expandtab | retab

  " Two-space indents in json
  autocmd! FileType json set sw=2 sts=2 expandtab

  " Hitting K in a Ruby file opens rdoc, which completely breaks the terminal
  " to the point of having to kill vim and do `reset`. Unmap it entirely.
  nnoremap K <Nop>

  " Compute syntax highlighting from beginning of file. (By default, vim only
  " looks 200 lines back, which can make it highlight code incorrectly in some
  " long files.)
  autocmd BufEnter * :syntax sync fromstart

  " Vim 8.2 adds built-in JSX support which seems broken. Setting these
  " filetypes lets the installed plugins deal with JSX/TSX instead.
  autocmd bufnewfile,bufread *.tsx set filetype=typescript.tsx
  autocmd bufnewfile,bufread *.jsx set filetype=javascript.jsx

  " Execute Program courses are plaintext. Sometimes vim thinks they're 'conf'
  " files without this.
  autocmd bufnewfile,bufread *.course setlocal filetype=text tw=10000
augroup END

" =====
" COLOR
" =====
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

color palenight

" =====
" Tags
" =====

" Connect tags file
" Look in current dir first, then up to containing_dir
set tags+=./tags;,tags;
" On writing a file of the following types
au BufWritePost &.c,*.rb,*.js,*.go,*.py silent! ctags &

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ALE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'typescript': ['tsserver', 'eslint'],
      \ 'typescript.tsx': ['tsserver', 'eslint'],
      \ 'go': ['golint'],
      \ 'ruby': ['rubocop']
      \ }
let g:ale_fixers = {
      \ 'javascript': ['eslint'],
      \ 'typescript': ['prettier'],
      \ 'typescript.tsx': ['prettier'],
      \ 'ruby': ['rubocop'],
      \ 'go': ['gofmt', 'goimports'],
      \ '*': ['remove_trailing_lines', 'trim_whitespace']
      \ }
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_delay = 0
let g:ale_set_quickfix = 0
let g:ale_set_loclist = 0
let g:ale_javascript_eslint_executable = 'eslint --cache'
nnoremap gf :ALEFix<cr>
nnoremap gj :ALENextWrap<cr>
nnoremap gk :ALEPreviousWrap<cr>
nnoremap g1 :ALEFirst<cr>
" This mapping will kill all ALE-related processes (including tsserver). It's
" necessary when those processes get confused. E.g., tsserver will sometimes
" show type errors that don't actually exist. I don't know exactly why that
" happens yet, but I think that it's related to renaming files.
nnoremap g0 :ALEStopAllLSPs<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tsuquyomi
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim-ale handles TypeScript quickfix, so tell Tsuquyomi not to do it.
let g:tsuquyomi_disable_quickfix = 1

""""""""""""""
" FZF
""""""""""""""
noremap <leader>f :FZF<cr>

""""""""""""""
" NERDTree
""""""""""""""
map <leader>n :NERDTreeToggle<CR>
map <leader>nf :NERDTreeFind<CR>
let g:NERDTreeWinSize = 50

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC KEY MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>y "*y
" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>
" Can't be bothered to understand ESC vs <c-c> in insert mode
inoremap <c-c> <esc>
" <leader><leader> is more convenient than <c-^>
nnoremap <leader><leader> <c-^>
" Align selected lines
vnoremap <leader>ib :!align<cr>
" Close all other splits
nnoremap <leader>o :only<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SHORTCUT TO REFERENCE CURRENT FILE'S PATH IN COMMAND LINE MODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap <expr> %% expand('%:h').'/'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM-TEST
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:test#preserve_screen = 1
let test#ruby#rspec#executable = 'bundle exec rspec'
let test#strategy = "vimterminal"

nnoremap tf :TestFile<cr>
nnoremap tn :TestNearest<cr>
nnoremap tl :TestLast<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ack.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if executable('ag')
  let g:ackprg = 'ag --vimgrep --nocolor --ignore node_modules'
endif
cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>

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
map <leader>rn :call RenameFile()<cr>

" Automatically reload .vimrc file on save
augroup myvimrc
  au!
  au BufWritePost .vimrc so ~/.vimrc
augroup END

" Shortcuts for frequently accessed files
command! Vimrc e ~/.vimrc
command! Zshrc e ~/.zshrc
command! Gitconfig e ~/.gitconfig

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INSTANT MARKDOWN
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:instant_markdown_autostart = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UltiSnips
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-p>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col
        return "\<tab>"
    endif

    let char = getline('.')[col - 1]
    echom "CHAR"
    echom char
    echom "ENDCHAR"
    if char =~ '\k'
      echom "c-p"
        " There's an identifier before the cursor, so complete the identifier.
        return "\<c-p>"
    else
      echom "else"
        return "\<tab>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>
