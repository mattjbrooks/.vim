if exists('g:loaded_toggleNERDTree')
  finish
endif
let g:loaded_toggleNERDTree = 1

" Use <leader>t to toggle NERDTree.  Opens at directory of current file
" (equalizing windows first)
function TreeToggle()
  normal! \<C-w>=
  NERDTreeToggle %:p:h
endfunction

nnoremap <silent> <leader>t :silent call TreeToggle()<CR>
vnoremap <silent> <leader>t :<C-u>silent call TreeToggle()<CR>
