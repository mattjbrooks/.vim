if exists('g:loaded_toggleHyphen')
  finish
endif
let g:loaded_toggleHyphen = 1

" <F4> to toggle hyphen in list of word characters
function HyphenToggle()
  if &iskeyword =~ ',-'
    setlocal iskeyword-=-
  else
    setlocal iskeyword+=-
  endif
  return ''
endfunction

nnoremap <silent> <F4> :call HyphenToggle()<CR>
inoremap <F4> <C-R>=HyphenToggle()<CR>

" Used to indicate if hyphen is in list of word characters in statusline
function ReturnHyphen()
  if &iskeyword =~ ',-'
    return '- '
  else
    return ''
  endif
endfunction
