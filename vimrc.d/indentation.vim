" Workaround to improve indentation of javascript and php inside html

autocmd BufNewFile,BufRead *.html,*.xhtml setl syn=php | setl cinwords+=case,default

function CheckSyntax()
  if &ft == 'html' || &ft == 'xhtml'
    if !exists("*synstack")
      return
    else
      let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endif
    if len(syntaxlist) > 0 && getline('.') !~ "<script"
      for syntaxitem in syntaxlist
        if syntaxitem =~ "php" || syntaxitem =~ "javaScript"
          setlocal noautoindent nocindent smartindent indentexpr=
          return
        endif
      endfor
    endif
    setlocal noautoindent nocindent nosmartindent indentexpr=HtmlIndentGet(v:lnum)
  endif
endfunction

au insertEnter * :call CheckSyntax()
let g:funcsToExecOnCR = g:funcsToExecOnCR + ['CheckSyntax()']

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
