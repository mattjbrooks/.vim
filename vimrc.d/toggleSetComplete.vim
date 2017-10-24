" <F6> to toggle between completion using all buffers and tags
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

nnoremap <F6> :call SetCompleteToggle()<CR>
