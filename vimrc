set nocompatible                " Use Vim settings, rather than Vi (keep at start, because it changes other options)
set encoding=utf-8              " specify utf8 encoding
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set backup                      " keep a backup file
set backupdir=~/.vimbak,.       " save backup files in their own directory (remember to create ~/.vimbak)
set dir=~/.vimswap,.            " save swap files in their own directory (remember to create ~/.vimswap)
set history=200                 " keep 200 lines of command line history
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set incsearch                   " do incremental searching
set number                      " display line numbers
set hidden                      " allow switching between modified buffers without saving
set confirm                     " confirm whether to save file, instead of failing command
set autochdir                   " set working directory to file being edited
set wildmenu                    " use statusline to show possible completions for files and commands
set timeoutlen=600              " reduce time waited for mapped key sequences
set complete-=i                 " disable completion from include files
set shortmess+=I                " disable intro screen
set lazyredraw                  " don't redraw for untyped actions
set sessionoptions-=folds       " don't store folds in sessions
set noeb vb t_vb=               " disable bell and visualbell

" disable cursor keys in normal mode
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>

" also disable cursor keys in insert mode (except in auto/omnicomplete menus)
inoremap <Up> <C-R>=CursorKeyUp()<CR>
inoremap <Down> <C-R>=CursorKeyDown()<CR>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

" allow cursor key up/down in insert mode when navigating auto/omnicomplete menus
function CursorKeyUp()
  if pumvisible() != 0
    return "\<C-P>"
  else
    return ""
  endif
endfunction

function CursorKeyDown()
  if pumvisible() != 0
    return "\<C-N>"
  else
    return ""
  endif
endfunction

" show tabs and carriage returns
set list
set listchars=eol:¬,tab:»\ 

" cursorline on
set cursorline

" make vsplit put new pane on right
" make split put new pane below
set splitright
set splitbelow

" set fillchars for vertical splits and folds
" (escaping space with \ for fold)
set fillchars=vert:\│,fold:\ 

" set , as the leader key
let mapleader=","

" leader w to switch windows in normal mode
nnoremap <leader>w <C-w>w

" leader h,j,k,l to switch windows left,down,up,right in normal mode
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" leader o to maximise current window
nnoremap <leader>o <C-w>o

" leader r to rotate windows
nnoremap <leader>r <C-w>r

" <leader>= to equalize windows
nnoremap <leader>= <C-w>=

" <leader>| to maximize current window width
nnoremap <leader>\| <C-w>\|

" Ctrl + Up and Ctrl + Down to resize windows
nnoremap <C-Down> <C-w><
nnoremap <C-Up> <C-w>>

" <leader><leader> to clear search pattern
nnoremap <silent> <leader><leader> :let @/ = ""<CR>:echo<CR>

" <leader>cd to change to directory of the currently open file
" (left in case set autochdir ever needs to be disabled)
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" SS command to save current session at ~/.vimsession
command SS mksession! ~/.vimsession | echo "Saved current session"

" L command to load session stored at ~/.vimsession
command L source ~/.vimsession | syn sync fromstart | let @/ = ""

" <leader>J to join lines (due to next mapping)
nnoremap <leader>J J

" J and K to move to prev/next buffer
nnoremap <silent> J :bprev<CR>
vnoremap <silent> J :<C-u>bprev<CR>
nnoremap <silent> K :bnext<CR>
vnoremap <silent> K :<C-u>bnext<CR>

" ctrl+j to scroll down 2 lines, ctrl+k to scroll up 2 lines
nnoremap <C-j> 2<C-e>
nnoremap <C-k> 2<C-y>

" reselect after indent/outdent in visual mode
vnoremap < <gv
vnoremap > >gv

" Folding preferences:
set foldmethod=indent
set foldignore=
set foldnestmax=20
set foldlevel=99

function MyFoldText()
  let lines = v:foldend - v:foldstart + 1
  let txt = '+ ' . lines
  return txt
endfunction
set foldtext=MyFoldText()

" Don't use Ex mode, use Q to replay the macro recorded using qq
nnoremap Q @q

" Quit if NERDTree is the only open window
autocmd BufEnter *
  \ if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") |
  \ q | endif

" Sudow command to write with sudo
command Sudow execute "w !sudo tee % > /dev/null && sudo -k"

" TS command to split the tmux window, creating a smaller window under the current
command TS silent execute "!tmux splitw -p 20" | execute ":redraw!"

" Avoid E173 on quit
if argc() > 1
  silent blast
  silent bfirst
endif

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
else
  set autoindent " always set autoindenting on
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

" Use modified color scheme
colors matts_modified_scheme
