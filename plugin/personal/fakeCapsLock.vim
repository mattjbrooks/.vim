if exists('g:loaded_fakeCapsLock')
  finish
endif
let g:loaded_fakeCapsLock = 1

" shift+tab in insert mode as fake caps lock (have caps remapped to Esc)
let s:fakeCapsLock = 0

function FakeCaps()
  if pumvisible() != 0
    " if in auto/omnicomplete menu, move up on shift+tab instead
    return "\<C-P>"
  endif
  if s:fakeCapsLock == 0
    let s:fakeCapsLock = 1
    let asciival = 97
    while asciival <= 122
      let lowerCase = nr2char(asciival)
      let upperCase = toupper(lowerCase)
      execute 'inoremap ' . lowerCase . ' ' . upperCase
      let asciival = asciival + 1
    endwhile
  else
    let s:fakeCapsLock = 0
    let asciival = 97
    while asciival <= 122
      let lowerCase = nr2char(asciival)
      execute 'iunmap ' . lowerCase
      let asciival = asciival + 1
    endwhile
  endif
  return ''
endfunction

function NoCaps()
  if s:fakeCapsLock == 1
    let s:fakeCapsLock = 0
    let asciival = 97
    while asciival <= 122
      let lowerCase = nr2char(asciival)
      execute 'iunmap ' . lowerCase
      let asciival = asciival + 1
    endwhile
  endif
endfunction

inoremap <S-Tab> <C-R>=FakeCaps()<CR>
autocmd InsertLeave * call NoCaps()

" Used to indicate if fake caps is active in statusline
function ReturnCaps()
  if s:fakeCapsLock
    return "[CAPS] "
  else
    return ""
  endif
endfunction
