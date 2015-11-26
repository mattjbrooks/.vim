" Workaround to improve php indentation inside html

autocmd BufNewFile,BufRead *.html,*.xhtml setl syn=php | setl cinwords+=case,default

function CheckForPHP()
  if &ft == 'html' || &ft == 'xhtml'
    if !exists("*synstack")
      return
    else
      let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endif
    if len(syntaxlist) > 0
      if syntaxlist[0] =~ "php"
        " We're in a php block
        setlocal noautoindent nocindent smartindent indentexpr=
      endif
    else
      setlocal noautoindent nocindent nosmartindent indentexpr=HtmlIndentGet(v:lnum)
    endif
  endif
endfunction

au insertEnter * :call CheckForPHP()
let g:funcsToExecOnCR = g:funcsToExecOnCR + ['CheckForPHP()']

" F6 in normal mode to toggle the above for *.php files by switching ft

let s:useHTMLFiletype = 0

function ToggleHTMLFiletype()
  let extension = expand('%:e')
  if extension == 'php'
    if s:useHTMLFiletype
      let s:useHTMLFiletype = 0
      setlocal ft=php
      echo 'php'
    else
      let s:useHTMLFiletype = 1
      setlocal ft=html
      setlocal syn=php
      echo 'html + smart'
    endif
  endif
endfunction

function UseHTMLFiletype()
  if s:useHTMLFiletype
    setlocal ft=html
    setlocal syn=php
  else
    setlocal ft=php
  endif
endfunction

nnoremap <silent> <F6> :call ToggleHTMLFiletype()<CR>

autocmd BufNewFile,BufRead *.php call UseHTMLFiletype()
