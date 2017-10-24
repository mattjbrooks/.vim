" <F6> to toggle between completion using all buffers and tags
" and completion only using the current buffer

function SetCompleteToggle()
  if &complete != '.'
    set complete=.
    echo "set complete=."
  else
    set complete=.,w,b,u,t
    echo "set complete=.,w,b,u,t"
  endif
endfunction

nnoremap <F6> :call SetCompleteToggle()<CR>
