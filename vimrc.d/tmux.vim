if exists('g:loaded_tmux')
  finish
endif
let g:loaded_tmux = 1

" Configure keys when we are in tmux and TERM is screen(-256color) rather
" than xterm(-256color).  Using Ctrl-v in insert mode then desired key(s) to
" produce control code.  Needs 'set-window-option -g xterm-keys on' in
" .tmux.conf
if &term =~ '^screen'
  " Disable arrow keys (in hjkl order)
  map OD <NOP>
  map OB <NOP>
  map OA <NOP>
  map OC <NOP>
  " Map Ctrl + arrow keys
  map [1;5D <C-Left>
  map [1;5B <C-Down>
  map [1;5A <C-Up>
  map [1;5C <C-Right>
  " Map Alt + arrow keys
  map [1;3D <M-Left>
  map [1;3B <M-Down>
  map [1;3A <M-Up>
  map [1;3C <M-Right>
endif
