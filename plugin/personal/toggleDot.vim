if exists('g:loaded_toggleDot')
  finish
endif
let g:loaded_toggleDot= 1

" <leader>. to toggle full stop in list of word characters
function DotToggle()
  if &iskeyword =~ ',\.'
    setlocal iskeyword-=.
  else
    setlocal iskeyword+=.
  endif
  return ''
endfunction

nnoremap <silent> <leader>. :call DotToggle()<CR>

" Used to indicate if full stop is in list of word characters in statusline
function ReturnDot()
  if &iskeyword =~ ',\.'
    return '. '
  else
    return ''
  endif
endfunction
