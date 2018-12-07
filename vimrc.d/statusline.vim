" The default statusline for reference:
" set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Modified statusline example:
" set statusline=%{&ff!='unix'?'[WARNING:\ '.&ff.'\ fileformat]\ ':''}%<%f\ %h%{&mod?'[modified]\ ':''}%{ReturnCaps()}%{ReturnDot()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P

" Show warning if fileformat is not unix
" Make modified flag more obvious
" Show if fake caps is active (see fakeCapsLock.vim)
" Show if hyphen or full stop in list of word characters (see toggleHyphen.vim and toggleDot.vim)

function StatuslineString(...)
  " If optional argument is provided to StatuslineString containing 'fullpath'
  if a:0 == 1 && a:1 =~ 'fullpath'
    let pathing = '%F'
  else
    let pathing = '%f'
  endif
  let statuslineString = '%{&ff!=''unix''?''[WARNING:\ ''.&ff.''\ fileformat]\ '':''''}%<'
  let statuslineString .= pathing
  let statuslineString .= '\ %h%{&mod?''[modified]\ '':''''}%{ReturnCaps()}%{ReturnDot()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P'
  return statuslineString
endfunction

execute 'set statusline=' . StatuslineString('')

" statusline visible
set laststatus=2

" set highlighting for non-current windows
highlight StatusLineNC cterm=none ctermfg=242 ctermbg=235

" change statusline colours in insert mode
autocmd InsertEnter * highlight StatusLine cterm=none ctermfg=252 ctermbg=236
autocmd InsertLeave * silent call SetStatuslineBackground()

function SetStatuslineBackground()
  if tabpagewinnr(tabpagenr(), '$') == 1
    highlight StatusLine cterm=bold ctermfg=032 ctermbg=none
  else
    highlight StatusLine cterm=bold ctermfg=032 ctermbg=236
  endif
endfunction()

function CheckFilename()
  " Check if the tail of the filename of the current buffer matches any others which are listed.
  " If so, use full path in the statusline.
  let listed_buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let tail = expand("%:t")
  if tail != ""
    for buffer in listed_buffers
      if expand("#".buffer.":t") == tail
        if bufnr('%') != buffer
          execute 'set statusline=' . StatuslineString("fullpath")
          return
        endif
      endif
    endfor
  endif
endfunction

autocmd WinEnter,BufEnter,TabEnter * silent call SetStatuslineBackground()
autocmd BufEnter * silent call CheckFilename()
