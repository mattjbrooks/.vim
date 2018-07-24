" The default statusline for reference:
" set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Modified statusline:
" Show warning if fileformat is not unix
" Make modified flag more obvious
" Show if fake caps is active (see fakeCapsLock.vim)
" Show if hyphen or full stop in list of word characters (see toggleHyphen.vim and toggleDot.vim)

set statusline=%{&ff!='unix'?'[WARNING:\ '.&ff.'\ fileformat]\ ':''}%<%f\ %h%{&mod?'[modified]\ ':''}%{ReturnCaps()}%{ReturnDot()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P

" statusline visible
set laststatus=2

" set highlighting for non-current windows
highlight StatusLineNC cterm=none ctermfg=242 ctermbg=235

" change statusline colours in insert mode
autocmd InsertEnter * highlight StatusLine cterm=none ctermfg=252 ctermbg=236
autocmd InsertLeave * silent call SetStatusline()

function SetStatusline()
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
          set statusline=%{&ff!='unix'?'[WARNING:\ '.&ff.'\ fileformat]\ ':''}%<%F\ %h%{&mod?'[modified]\ ':''}%{ReturnCaps()}%{ReturnDot()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P
          return
        endif
      endif
    endfor
  endif
endfunction

autocmd WinEnter,BufEnter,TabEnter * silent call SetStatusline()
autocmd BufEnter * silent call CheckFilename()
