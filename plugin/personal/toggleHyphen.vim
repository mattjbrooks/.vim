if exists('g:loaded_toggleHyphen')
  finish
endif
let g:loaded_toggleHyphen = 1

" <leader>- to toggle hyphen in list of word characters
function HyphenToggle()
  if &iskeyword =~ ',-'
    setlocal iskeyword-=-
  else
    setlocal iskeyword+=-
  endif
  return ''
endfunction

nnoremap <silent> <leader>- :call HyphenToggle()<CR>

" Used to indicate if hyphen is in list of word characters in statusline
function ReturnHyphen()
  if &iskeyword =~ ',-'
    return '- '
  else
    return ''
  endif
endfunction
