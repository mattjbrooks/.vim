" <F8> to toggle between completion using all buffers and tags (default)
" and completion only using the current buffer

function SetCompleteToggle()
  if &complete == '.'
    set complete=.,w,b,u,t
    echo "set complete=.,w,b,u,t"
  else
    set complete=.
    echo "set complete=."
  endif
endfunction

nnoremap <F8> :call SetCompleteToggle()<CR>
