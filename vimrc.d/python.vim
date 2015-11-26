" add #! /usr/bin/python3 header to start of .py files then use normal mode G
" to move cursor to last line
autocmd BufNewFile *.py silent! 0r ~/.vim/headers/py3header | normal G

" highlight column 80 when entering python buffers or windows
function ColorCol()
  if &ft == 'python'
    setlocal cc=80
  endif
endfunction

autocmd BufEnter,WinEnter * call ColorCol()
