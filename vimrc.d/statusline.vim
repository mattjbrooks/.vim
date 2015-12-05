" The default statusline for reference:
" set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Show warning if fileformat is not unix, make modified flag more obvious,
" show caps lock and whether hyphen in word characters (uses ReturnCaps() from fakeCapsLock.vim and ReturnHyphen() from toggleHyphen.vim)
set statusline=%{&ff!='unix'?'[WARNING:\ '.&ff.'\ fileformat]\ ':''}%<%f\ %h%{&mod?'[modified]\ ':''}%{ReturnCaps()}%{ReturnHyphen()}%r%=%-14.(%l,%c%V%)\ %P

" statusline visible
set laststatus=2

" change statusline colours in insert mode
autocmd InsertEnter * highlight StatusLine cterm=none ctermfg=white ctermbg=238
autocmd InsertLeave * highlight StatusLine cterm=bold ctermfg=032 ctermbg=none

" clear the effect if the cursor moves after entering the window or if the cursor hasn't moved
" in <updatetime> milliseconds, or if there is only one window in the current tab page
let s:doClear = 0

function ClearStatusline()
  highlight StatusLine cterm=bold ctermfg=032 ctermbg=none
  let s:doClear = 0
endfunction

function ClearOnHold()
  if s:doClear
    silent call ClearStatusline()
  endif
endfunction

function ClearOnMove()
  " The cursor's move when entering a new window will trigger this function, setting s:doClear to 1.
  " Then the next time the cursor moves the statusline effect will be cleared if still active.
  if s:doClear == 2
    let s:doClear = 1
  elseif s:doClear == 1
    silent call ClearStatusline()
  endif
endfunction

function ClearIfOnlyWindow()
  if tabpagewinnr(tabpagenr(), '$') == 1
    silent call ClearStatusline()
  endif
endfunction()

" set updatetime=4000
autocmd CursorHold * silent call ClearOnHold()
autocmd CursorMoved * silent call ClearOnMove()
autocmd BufEnter,TabEnter * silent call ClearIfOnlyWindow()
autocmd WinEnter * highlight StatusLine cterm=none ctermfg=252 ctermbg=024 | let s:doClear = 2
