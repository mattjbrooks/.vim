" On carriage return execute the functions named in g:funcsToExecOnCR
" (used in completion.vim and indentation.vim to respond to
" carriage return by adding functions to the g:funcsToExecOnCR list)

let g:funcsToExecOnCR = []

function DoCRFuncs()
  for myFunction in g:funcsToExecOnCR
    execute "call " . myFunction
  endfor
  return ''
endfunction

inoremap <silent><CR> <C-R>=DoCRFuncs()<CR><CR>
