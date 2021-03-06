if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

" Default statusline:
" set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Currently modified to show warning if fileformat is not unix,
" make modified flag more visible, show if fake caps lock is active,
" or if hyphen or full stop in list of word characters.
" (see functions in fakeCapsLock.vim, toggleHyphen.vim, toggleDot.vim)

function StatuslineString(...)
  if a:0 == 1 && a:1 =~ 'fullpath' " if optional argument is provided to StatuslineString containing 'fullpath'
    let pathing = '%F' " use full paths in statusline
  else
    let pathing = '%f' " use paths relative to the current directory
  endif
  let statuslineString = '%{&ff!=''unix''?''[WARNING:\ ''.&ff.''\ fileformat]\ '':''''}%<'
  let statuslineString .= pathing
  let statuslineString .= '\ %h%{&mod?''[modified]\ '':''''}%{ReturnCaps()}%{ReturnDot()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P'
  return statuslineString
endfunction

function CheckFilename()
  " Check if the tail of the filename of the current buffer matches any others which are listed.
  " If so, use full path in the statusline.
  let listed_buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let tail = expand("%:t")
  if tail != ""
    for buffer in listed_buffers
      if expand("#".buffer.":t") == tail
        if bufnr('%') != buffer
          execute 'set statusline=' . StatuslineString('fullpath')
          return
        endif
      endif
    endfor
  endif
endfunction

function SetHighlighting()
  if tabpagewinnr(tabpagenr(), '$') == 1
    highlight StatusLine cterm=bold ctermfg=032 ctermbg=none
  else
    highlight StatusLine cterm=bold ctermfg=032 ctermbg=236
  endif
endfunction()

execute 'set statusline=' . StatuslineString('')

" statusline visible
set laststatus=2

" set highlighting for non-current windows
highlight StatusLineNC cterm=none ctermfg=242 ctermbg=235

autocmd WinEnter,BufEnter,TabEnter * silent call SetHighlighting()
autocmd BufEnter * silent call CheckFilename()
autocmd InsertEnter * highlight StatusLine cterm=none ctermfg=252 ctermbg=236
autocmd InsertLeave * silent call SetHighlighting()
