" <F5> in normal mode to between default behaviour of yank/paste/delete
" and using clipboard (with <leader>d to delete to the clipboard in visual mode)
" Requires version of vim with clipboard support (check for +clipboard in output of
" vim --version)
let s:yankAndPaste = "default"

function ClipboardToggle()
  if s:yankAndPaste == "default"
    let s:yankAndPaste = "clipboard"
    nnoremap y "+y
    vnoremap y "+y
    nnoremap Y "+Y
    vnoremap Y "+Y
    nnoremap p "+p
    vnoremap p "+p
    nnoremap P "+P
    vnoremap P "+P
    vnoremap <leader>d "+d
    echo "clipboard"
  else
    let s:yankAndPaste = "default"
    nunmap y
    vunmap y
    nunmap Y
    vunmap Y
    nunmap p
    vunmap p
    nunmap P
    vunmap P
    vunmap <leader>d
    echo "default"
  endif
endfunction

nnoremap <F5> :call ClipboardToggle()<CR>
