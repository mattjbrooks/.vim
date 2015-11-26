" Use <leader>t to toggle NERDTree.  Opens at directory of current file
" (equalizing windows first)
function TreeToggle()
  normal! \<C-w>=
  NERDTreeToggle %:p:h
  echo
endfunction

nnoremap <silent> <leader>t :call TreeToggle()<CR>
vnoremap <silent> <leader>t :<C-u>call TreeToggle()<CR>
