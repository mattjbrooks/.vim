" Spaghetti for snippets and tab completion

" Assign starting values of variables for buffer if not already set
function SetBufVars()
  if !exists("b:navigating_snippet")
    let b:navigating_snippet = 0
  endif
  if !exists("b:multiline_snippet_entry")
    let b:multiline_snippet_entry = 0
  endif
  if !exists("b:did_snippet_nav")
    let b:did_snippet_nav = 0
  endif
endfunction

autocmd BufNewFile,BufRead,BufEnter * call SetBufVars()

function CurrentCharacter()
  " Returns the character under the cursor (uses registers to ensure it works for digraphs)
  " store the current contents of register c
  let registerContents = getreg('c')
  " yank the character under cursor into register c
  normal! "cyl
  let currentCharacter = getreg('c')
  " restore original contents of register c
  call setreg('c', registerContents)
  return currentCharacter
endfunction

function FindFolderPath()
  " Set the folder to look for snippet
  let pathtofolder = "~/.vim/snippets/"
  let extension = expand('%:e')
  if &ft == 'python'
    let pathtofolder = pathtofolder . "python/"
  elseif &ft == 'javascript'
    let pathtofolder = pathtofolder . "javascript/"
  elseif extension == 'php'
    let pathtofolder = pathtofolder . "php/"
  elseif &ft == 'html' || &ft == 'xhtml'
    let pathtofolder = pathtofolder . "html/"
  endif
  return pathtofolder
endfunction

function FixIndentation(linesinsnippet)
  if &ft != "python"
    execute 'normal! '.a:linesinsnippet.'=='
    " delete previous word and join lines
    normal! bdwJ
  else
    " Start of python specific bit:
    " Get the current cursor column
    let posbefore = col(".")
    normal! bdwJ
    " Get the position of first nonspace character on line
    let startofline = match(getline('.'),'\S')+1
    if startofline > posbefore && a:linesinsnippet > 1
      let spacesneeded = startofline - posbefore
      " We want to add the offset to the start of every line below the current one until the end of the snippet
      let linebelow = line('.') + 1
      let endofsnippet = linebelow + a:linesinsnippet - 2 " for a 2 line snippet endofsnippet == linebelow
      let stringofspaces = repeat(' ',spacesneeded)
      " Now we search and add the string to the start of the required lines, the normal! `` at the end returns the
      " cursor to the correct positon
      execute 'silent '. linebelow . ',' . endofsnippet . 's/^/' . stringofspaces . '/ |normal! ``'
    endif
    " End of python specific bit
  endif
endfunction

function CarriageReturnInEntry()
  " Check we are navigating snippet and have navigated to at least the first entry:
  if b:navigating_snippet == 1 && b:did_snippet_nav == 1
    let b:multiline_snippet_entry = 1
  endif
  " Disable snippet navigation so we can use tabs in multiline entry (use tab in normal mode to continue navigation)
  let b:navigating_snippet = 0
  return ''
endfunction

let g:funcsToExecOnCR = g:funcsToExecOnCR + ['CarriageReturnInEntry()']

function FindNextEntry()
  let b:done_all_entries = 0
  let character = CurrentCharacter()
  if character != "«"
    " If we are not over a « search for the next «» or «word»
    let dosearch = search('«\w*»')
  endif
  let character = CurrentCharacter()
  if character == "«"
    " if it's a « delete it and get the next character
    normal! x
    let character = CurrentCharacter()
    if character != "»"
      " if it's not a » (because we have a «word» rather than a «»), delete til the »
      normal! dt»
    endif
    " check whether at end of line before deleting » (need to check if current col = col("$") - 2
    " as « takes up two cols)
    if col(".") == col("$") - 2
      " we're at the end of the line so delete the » and append
      normal! x
      startinsert!
    else
      " there's more on the line after the » so delete the » then insert
      normal! x
      startinsert
    endif
    let b:did_snippet_nav = 1
  else
    let b:done_all_entries = 1
  endif
endfunction

function InsertATab()
  if col(".") == col("$") - 1 
    startinsert! " if we're at the end of the line we need to append
  endif
  " insert a tab (triggers InsertModeTabMod() with b:navigating_snippet set to zero)
  if b:did_snippet_nav == 1
    call feedkeys("\<Tab>")
  endif
endfunction

function SnippetNav()
  call FindNextEntry()
  let b:multiline_snippet_entry = 0
  if b:done_all_entries && b:navigating_snippet
    let b:navigating_snippet = 0
    call InsertATab()
  endif
endfunction

function SnippetLoad()
  " Get the character under the cursor
  let character = CurrentCharacter()
  " Get the ascii value of that character
  let ascii = char2nr(character)
  " Check if cursor is over alphanumeric character (as <cword> will still return word
  " when over non-alphanumeric characters before word, such as space, where we do not
  " want to expand snippet)
  if (ascii >= 48 && ascii <= 57) || (ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122)
    let pathtofolder = FindFolderPath()
    let pathtofile = pathtofolder . expand("<cword>")
    " Check if filename readable
    if filereadable(glob(pathtofile))
      " Delete anything on line after cursor position
      normal! lD
      let linesbefore = line('$') " Count number of lines
      " load snippet starting on line below (without following the indentation of current line)
      execute 'silent! r' . pathtofile
      " set did_snippet_nav to zero as we have just loaded a new snippet and have not yet navigated to first entry
      let b:did_snippet_nav = 0
      let linesafter = line('$')
      let linesinsnippet = linesafter - linesbefore
      call FixIndentation(linesinsnippet)
      " Get the character under the cursor
      let character = CurrentCharacter()
      " If the character is a space delete it (gets rid of space if added by join)
      if character == " "
        normal! x
      endif
      " Turn on snippet navigation
      let b:navigating_snippet = 1
      " try to jump to first occurrence
      call SnippetNav()
    else " Filename not readable
      if b:multiline_snippet_entry
        call SnippetNav() " If a multiline entry try to nav to next entry
      else
        echo "Not found in " . pathtofolder
      endif
    endif
  else " Cursor was not over an alphanumeric character
    if b:multiline_snippet_entry
      call SnippetNav() " If a multiline entry try to nav to next entry
    endif
  endif
endfunction

function CheckForEntries()
  if b:navigating_snippet == 1
    let line_num = line('.')
    while line_num <= line('$')
      if match(getline(line_num), '«\w*»') != -1
        return
      endif
      let line_num = line_num + 1
    endwhile
    let line_num = line('.') - 1
    while line_num > 0
      if match(getline(line_num), '«\w*»') != -1
        return
      endif
      let line_num = line_num - 1
    endwhile
    let b:navigating_snippet = 0
  endif
endfunction
    
" Snippet insertion in normal mode:
function NormalModeTabMod()
  call CheckForEntries()
  if b:navigating_snippet
    call SnippetNav()
  else
    call SnippetLoad()
  endif
endfunction

" Tab completion in insert mode:
function InsertModeTabMod()
  if &ft =~ 'html' || &ft == 'php'
    " get the two characters to the left of the cursor
    let previous_chars = getline('.')[col('.')-3 : col('.')-2]
    if previous_chars == "<\/"
      let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
      if &ft == "htmldjango"
        let positioning = "A"
      else
        let positioning = "==A"
      endif
      if len(syntaxlist) > 0
        for syntaxitem in syntaxlist
          if syntaxitem == "htmlEndTag"
            return "\<C-x>\<C-o>\<Esc>" . positioning
          endif
        endfor
      endif
      return "script>\<Esc>a\<Esc>==A"
    endif
  endif
  if b:navigating_snippet == 1 " if we are navigating rather than loading snippets
    call SnippetNav()   " call SnippetNav() to jump to next «»
  else
    if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
      return "\<C-N>"
    else
      " Check pumvisible() in case using omnicomplete menu
      " lets us use tab to navigate through it
      if pumvisible() != 0
        return "\<C-N>"
      else 
        return "\<Tab>"
      endif
    endif
  endif
  return ''
endfunction

" <leader><Tab> in normal mode to manually toggle between snippet loading and snippet navigation
function SnippetToggle()
  if b:navigating_snippet == 1 || b:multiline_snippet_entry == 1
    let b:navigating_snippet = 0
    let b:multiline_snippet_entry = 0
    echo "snippet nav off"
  else
    let b:navigating_snippet = 1
    echo "snippet nav on"
  endif
endfunction

nnoremap <leader><Tab> :call SnippetToggle()<CR>

" Modify tab behaviour in normal and insert mode
nnoremap <silent> <Tab> :call NormalModeTabMod()<CR>
inoremap <silent> <Tab> <C-R>=InsertModeTabMod()<CR>
