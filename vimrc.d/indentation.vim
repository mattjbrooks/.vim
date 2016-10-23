" Workaround to improve indentation of javascript and php inside html

autocmd BufNewFile,BufRead *.html,*.xhtml setl cinwords+=case,default
autocmd FileType html,xhtml setl syn=php
autocmd FileType htmldjango setl noautoindent nocindent smartindent indentexpr=

function CheckSyntax()
  if &ft == 'html' || &ft == 'xhtml'
    if !exists("*synstack")
      return
    else
      let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endif
    let line_contents = getline('.')
    if len(syntaxlist) > 0 && line_contents !~ "<script"
      for syntaxitem in syntaxlist
        if syntaxitem =~ "php" || syntaxitem =~ "javaScript"
          setlocal noautoindent nocindent smartindent indentexpr=
          return
        endif
      endfor
    elseif len(syntaxlist) == 0
      if line_contents =~ "{% extends" || line_contents =~ "{% block" || line_contents =~ "{% load" || line_contents =~ "{#"
        setlocal ft=htmldjango
        setlocal syn=htmldjango
        setlocal noautoindent nocindent smartindent indentexpr=
        return
      endif
    endif
    setlocal noautoindent nocindent nosmartindent indentexpr=HtmlIndentGet(v:lnum)
  endif
endfunction

autocmd insertEnter * :call CheckSyntax()
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
