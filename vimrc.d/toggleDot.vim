" <F3> to toggle full stop in list of word characters
function DotToggle()
  if &iskeyword =~ ',\.'
    setlocal iskeyword-=.
  else
    setlocal iskeyword+=.
  endif
  return ''
endfunction

nnoremap <silent> <F3> :call DotToggle()<CR>
inoremap <F3> <C-R>=DotToggle()<CR>

" Used to indicate if full stop is in list of word characters in statusline
function ReturnDot()
  if &iskeyword =~ ',\.'
    return '. '
  else
    return ''
  endif
endfunction
