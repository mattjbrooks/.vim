if exists('g:loaded_toggleSetComplete')
  finish
endif
let g:loaded_toggleSetComplete = 1

" <F6> to toggle between completion using all buffers and tags (default)
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
