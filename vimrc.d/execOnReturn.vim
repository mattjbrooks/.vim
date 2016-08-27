" On carriage return execute the functions named in g:funcsToExecOnCR
" (used in completion.vim and indentation.vim to respond to
" carriage return by adding functions to the g:funcsToExecOnCR list)

let g:funcsToExecOnCR = []

function DoCRFuncs()
  let numOfFuncs = len(g:funcsToExecOnCR)
  let currentFunc = 0
  while currentFunc < numOfFuncs
    execute "call " . g:funcsToExecOnCR[currentFunc]
    let currentFunc = currentFunc + 1
  endwhile
  return ''
endfunction

inoremap <silent><CR> <C-R>=DoCRFuncs()<CR><CR>
