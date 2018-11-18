" add #! /usr/bin/python3 header to start of .py files then use normal mode G
" to move cursor to last line
" autocmd BufNewFile *.py silent! 0r ~/.vim/headers/py3header | normal G

" highlight column 80 when entering python buffers or windows
function ColorCol()
  if &ft == 'python'
    setlocal cc=80
  endif
endfunction

function MatchBracketPos()
  let line_content = getline(".")
  let brackets = [')', '}', ']']
  for bracket in brackets
    if match(line_content, '^\s*' . bracket . '$') != -1
      " Add bracket, move up and delete line using black hole register,
      " then begin a new line below
      call feedkeys(bracket . "\<Esc>k\"_ddo")
  endif
  endfor
endfunction

let g:funcsToExecOnCR = g:funcsToExecOnCR + ['MatchBracketPos()']
autocmd BufEnter,WinEnter * call ColorCol()
