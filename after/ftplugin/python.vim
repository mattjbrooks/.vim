" Highlight column 80
setl cc=80

" highlight groups of 4 spaces when first entering insert mode,
" switch off when leaving or if cursor moves
au InsertEnter *.py highlight FourSpaces cterm=none ctermbg=236 | match FourSpaces /\s\s\s\s/
au CursorMovedI *.py highlight FourSpaces cterm=none ctermbg=none
au InsertLeave *.py highlight FourSpaces cterm=none ctermbg=none

" highlight trailing space in blue
" highlight TrailSpace ctermbg=blue
" match TrailSpace / \+$/
