" By default disable comment continuation
autocmd BufWinEnter,BufEnter * set formatoptions-=cr | set formatoptions-=o | hi comment ctermbg=none

" use shift+enter to toggle comment continuation on and off
" highlight comments to indicate if continuation is active
function ShiftEnterMod()
  if &formatoptions=~#'r'
    set formatoptions-=cr
    highlight comment ctermbg=none
  else
    set formatoptions+=cr
    highlight comment ctermbg=235
  endif
  return "\<CR>"
endfunction

" shift+enter mapping to toggle comment continuation (works in Konsole but may not work in other terminals)
inoremap OM <C-R>=ShiftEnterMod()<CR>
