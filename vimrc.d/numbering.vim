" <F3> to toggle between standard and relative line numbering
function SetupVar()
  if !exists("b:relative_numbering")
    let b:relative_numbering = 0
  endif
endfunction

autocmd BufNewFile,BufRead,BufEnter * call SetupVar()

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

" Switch to relative numbering on first entering visual mode, switch back
" when the cursor moves
function SwitchToRelative()
  if !exists("b:NERDTreeType")
    setl relativenumber
  endif
endfunction

function SwitchToAbsolute()
  if &relativenumber
    if b:relative_numbering == 0
      setl number
      setl norelativenumber
    endif
  endif
endfunction

nnoremap <silent> v :call SwitchToRelative()<CR>v
nnoremap <silent> V :call SwitchToRelative()<CR>V
nnoremap <silent> <C-v> :call SwitchToRelative()<CR><C-v>
autocmd CursorMoved * silent call SwitchToAbsolute()
