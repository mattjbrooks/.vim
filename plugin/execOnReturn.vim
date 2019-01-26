" On carriage return execute the functions named in g:funcsToExecOnCR
" (used in completion.vim, pythonSettings.vim and indentationBodge.vim
" to respond to carriage return)

let g:funcsToExecOnCR = []

function DoCRFuncs()
  for myFunction in g:funcsToExecOnCR
    execute "call " . myFunction
  endfor
  return ''
endfunction

inoremap <silent><CR> <C-R>=DoCRFuncs()<CR><CR>
