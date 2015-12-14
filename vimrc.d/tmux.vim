" Configure keys when we are in tmux and TERM is screen(-256color) rather
" than xterm(-256color).  Using Ctrl-v in insert mode then desired key(s) to
" produce control code.  Needs 'set-window-option -g xterm-keys on' in
" .tmux.conf
if &term =~ '^screen'
  map OD <Left>
  map OB <Down>
  map OA <Up>
  map OC <Right>
  map [1;5D <C-Left>
  map [1;5B <C-Down>
  map [1;5A <C-Up>
  map [1;5C <C-Right>
endif
