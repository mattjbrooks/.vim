" <F2> to open html/xhtml file in firefox (need to create a no-plugins profile
" in firefox first with firefox -profilemanager), notifies once if file has
" been modified, if pressed again uses last saved version anyway
let s:shown_message = 0

function OpenInFirefox()
  if &ft == "html" || &ft == "xhtml"
    if !&modified || s:shown_message
      execute 'silent !firefox -P "no-plugins" "%:p"'
    endif
  endif
endfunction

function MessageIfModified()
  if &ft == "html" || &ft == "xhtml"
    if &modified && !s:shown_message
      redraw
      echo 'unsaved changes'
      let s:shown_message = 1
      return
    endif
  endif
  echo
  let s:shown_message = 0
endfunction

nnoremap <F2> :call OpenInFirefox()<CR><C-l>:call MessageIfModified()<CR>
