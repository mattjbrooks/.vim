function SetupVar()
  if !exists("b:relative_numbering")
    let b:relative_numbering = 0
  endif
endfunction

autocmd BufNewFile,BufRead,BufEnter * call SetupVar()

" <F3> to toggle between standard and relative line numbering
function LineNumToggle()
  if !exists("b:NERDTreeType") " Check we are not in NERDTree
    if b:relative_numbering
      setl number
      setl norelativenumber
      let b:relative_numbering = 0
    else
      setl relativenumber
      let b:relative_numbering = 1
    endif
  endif
endfunction

nnoremap <silent> <F3> :call LineNumToggle()<CR>

" Switch to relative numbering on first entering visual mode
function RelativeNumbering()
  if !exists("b:NERDTreeType")
    setl relativenumber
  endif
endfunction

" Switch back to original numbering when cursor moves in normal mode or on
" entering insert mode
function OrigNumbering()
  if &relativenumber
    if b:relative_numbering == 0
      setl number
      setl norelativenumber
    endif
  endif
endfunction

nnoremap <silent> v :call RelativeNumbering()<CR>v
nnoremap <silent> V :call RelativeNumbering()<CR>V
nnoremap <silent> <C-v> :call RelativeNumbering()<CR><C-v>
autocmd CursorMoved * silent call OrigNumbering()
autocmd InsertEnter * silent call OrigNumbering()
