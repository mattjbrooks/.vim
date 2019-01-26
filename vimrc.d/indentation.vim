" Workaround to improve indentation for files which combine html with other languages

if exists('g:loaded_indentation')
  finish
endif
let g:loaded_indentation = 1

let s:djangoTemplates = 1 " toggles whether to switch ft to htmldjango if line contains {# or {%

autocmd BufNewFile,BufRead *.html,*.xhtml setl cinwords+=case,default
autocmd FileType htmldjango setl noautoindent nocindent smartindent indentexpr=

function CheckSyntax()
  if &ft == 'html' || &ft == 'xhtml'
    if !exists("*synstack")
      return
    endif
    let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    let line_contents = getline('.')
    if Javascript(syntaxlist, line_contents)
      setlocal noautoindent nocindent smartindent indentexpr=
    elseif DjangoTemplate(syntaxlist, line_contents)
      setlocal ft=htmldjango syn=htmldjango
      syn sync fromstart
    else
      setlocal noautoindent nocindent nosmartindent indentexpr=HtmlIndentGet(v:lnum)
    endif
  endif
endfunction

function Javascript(syntaxlist, line_contents)
  if len(a:syntaxlist) > 0 && a:line_contents !~ "<script"
    for syntaxitem in a:syntaxlist
      if syntaxitem =~ "javaScript"
        return 1
      endif
    endfor
  endif
  return 0
endfunction

function DjangoTemplate(syntaxlist, line_contents)
  if s:djangoTemplates && len(a:syntaxlist) == 0
    if a:line_contents =~ "{%" || a:line_contents =~ "{#"
      let extension = expand('%:e')
      if &ft != 'htmldjango' && extension =~ 'html'
        return 1
      endif
    endif
  endif
  return 0
endfunction

autocmd insertEnter * :call CheckSyntax()
let g:funcsToExecOnCR = g:funcsToExecOnCR + ['CheckSyntax()']
