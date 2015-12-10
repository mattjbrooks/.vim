let s:start = 0 | let s:end = 1
let s:top = 0 | let s:bottom = 1
let s:left = 0 | let s:right = 1

function CommentList()
  let start_comment = ""
  let end_comment = ""
  let extension = expand('%:e')
  if &ft == 'vim'
    let start_comment = '"'
  elseif &ft == 'python' || &ft == 'sh'
    let start_comment = "#"
  elseif &ft == 'javascript' || extension == 'php'
    let start_comment = "//"
  elseif &ft == 'html' || &ft == 'xhtml'
    let start_comment = '<!--'
    let end_comment = '-->'
  elseif &ft == 'css'
    let start_comment = '/*'
    let end_comment = '*/'
  endif
  let comment_list = [start_comment, end_comment]
  return comment_list
endfunction

function FindLeftmost(line)
  let line_num = a:line[s:top]
  while line_num <= a:line[s:bottom]
    execute "normal! " . line_num . "gg"
    let current_line = getline('.')
    if current_line !~ '^\s*$'
      normal! ^
      let line_start = col('.')
      if !exists('leftmost_col') || line_start < leftmost_col
        let leftmost_col = line_start
      endif
    endif
    let line_num = line_num + 1
  endwhile
  if !exists('leftmost_col')
    let leftmost_col = 0
  endif
  return leftmost_col
endfunction

function CheckForString(line, position, string)
  let line_num = a:line[s:top]
  let slices_match_string = 1
  while line_num <= a:line[s:bottom]
    execute "normal! " . line_num . "gg"
    let current_line = getline('.')
    let slice_of_line = current_line[(a:position[s:left]):(a:position[s:right])]
    if slice_of_line != a:string && current_line !~ '^\s*$'
      let slices_match_string = 0
    endif
    let line_num = line_num + 1
  endwhile
  return slices_match_string
endfunction

function RemoveSpacesIfBlank()
  let current_line = getline('.')
  if current_line =~ '^\s*$'
    normal! 0d$
  endif
endfunction

function PlaceComment(left_col, comment)
  let left_pos = a:left_col - 1
  if left_pos == 0
    " If at start of line insert
    execute "normal! 0i" . a:comment
  else
    " Otherwise append
    execute "normal!" . left_pos . "\|"
    execute "normal! a" . a:comment
  endif
endfunction

function AppendComment(comment)
  execute "normal! A" . a:comment
endfunction

function RepositionAfterAdd(original_pos, left_col, comment_length)
  if a:original_pos >= a:left_col
    " Keep position if over text when comment is added
    let new_pos = a:original_pos + a:comment_length
    execute "normal! " . new_pos . "\|"
  else
    " Unless we were originally in the white space before the text,
    " when we want to stay where we were:
    execute "normal! " . a:original_pos . "\|"
  endif
endfunction

function RemoveStartComment(comment_length)
  normal! ^
  execute "normal! " . a:comment_length . "x"
endfunction

function RemoveEndComment(comment_length)
  if a:comment_length != 0
    normal! $
    execute "normal! " . (a:comment_length - 1) . "h"
    execute "normal! " . a:comment_length . "x"
  endif
endfunction

function RepositionAfterRemove(original_pos, left_col, comment_length)
  if a:original_pos >= a:left_col + a:comment_length
    " Keep position if over text when comment is deleted
    let new_pos = a:original_pos - a:comment_length
    execute "normal! " . new_pos . "\|"
  else
    " Unless we were originally in the white space or the comment string
    " before the text, when we want to stay where we were:
    execute "normal! " . a:original_pos . "\|"
  endif
endfunction

function SlicesFromLine(current_line, column, comment_len)
  let slice = ['', '']

  let left_pos = a:column[s:left] - 1
  let right_pos = left_pos + a:comment_len[s:start] - 1
  let slice[s:start] = a:current_line[(left_pos):(right_pos)]

  if a:comment_len[s:end] > 0
    let right_pos = a:column[s:right] - 1
    let left_pos = right_pos - a:comment_len[s:end] + 1
    let slice[s:end] = a:current_line[(left_pos):(right_pos)]
  endif

  return slice
endfunction

function IsLineCommented(slice, comment)
  let has_comment = [0,0]

  if a:slice[s:start] == a:comment[s:start]
    let has_comment[s:start] = 1
  endif

  if a:comment[s:end] != ""
    if a:slice[s:end] == a:comment[s:end]
      let has_comment[s:end] = 1
    endif
  endif

  return has_comment
endfunction

function SlicesFromSelection(line_contents, column, comment_len)
  let slices = [['',''],['','']]
  let slices[s:top] = SlicesFromLine(a:line_contents[s:top], a:column[s:top], a:comment_len)
  let slices[s:bottom] = SlicesFromLine(a:line_contents[s:bottom], a:column[s:bottom], a:comment_len)
  return slices
endfunction

function IsSelectionCommented(slices, comment)
  let has_comment = [['',''],['','']]
  let has_comment[s:top] = IsLineCommented(a:slices[s:top], a:comment)
  let has_comment[s:bottom] = IsLineCommented(a:slices[s:bottom], a:comment)
  return has_comment
endfunction

function VisualModeComment()

  " Get a list of strings to add or remove from lines
  let comment = CommentList()
  if comment[s:start] == ""
    return
  endif

  " Get a list of the length of those strings
  let comment_len = [len(comment[s:start]), len(comment[s:end])]

  let line = [0, 0]
  " Find start and end lines
  normal! \<Esc>`<
  let line[s:top] = line('.')
  normal! `>
  let line[s:bottom] = line('.')

  " Switch line_start and line_end if needed
  if line[s:top] > line[s:bottom]
    let line[s:bottom] = line[s:top]
    let line[s:top] = line('.')
  endif

  let paste = &paste
  set paste

  if comment[s:end] == ""
    " Find leftmost column
    let leftmost_col = FindLeftmost(line)

    " Find left and right pos where starting comment string would go
    let position = [0,0]
    let position[s:left] = leftmost_col - 1
    let position[s:right] = position[s:left] + comment_len[s:start] - 1
    
    " Check if any non-blank lines in highlighted text have no comment
    let all_commented = CheckForString(line, position, comment[s:start])

    " Add or remove comments to non blank lines
    if all_commented == 0
      let line_num = line[s:top]
      while line_num <= line[s:bottom]
        execute "normal! " . line_num . "gg"
        let current_line = getline('.')
        if current_line !~ '^\s*$'
          call PlaceComment(leftmost_col, comment[s:start] . " ")
        endif
        let line_num = line_num + 1
      endwhile
    else
      let line_num = line[s:top]
      while line_num <= line[s:bottom]
        execute "normal! " . line_num . "gg"
        let current_line = getline('.')
        let slice_of_line = current_line[(position[s:left]):(position[s:right])]
        if slice_of_line == comment[s:start]
          call RemoveStartComment(comment_len[s:start])
        endif
        let line_num = line_num + 1
      endwhile
      let position[s:right] = position[s:left]
      let all_have_space = CheckForString(line, position, " ")
      let line_num = line[s:top]
      if all_have_space
        while line_num <= line[s:bottom]
          execute "normal! " . line_num . "gg"
          normal! ^hx
          let line_num = line_num + 1
        endwhile
      endif
    endif
  else " if comment[s:end] != ''
    " (ie if the current comment type has an end string as well as a start string)
    let line_contents = ['','']
    let column = [[0,0],[0,0]]

    execute "normal! " . line[s:top] . "gg"
    let line_contents[s:top] = getline('.')
    normal! ^
    let column[s:top][s:left] = col('.')
    normal! $
    let column[s:top][s:right] = col('.')

    execute "normal! " . line[s:bottom] . "gg"
    let line_contents[s:bottom] = getline('.')
    normal! ^
    let column[s:bottom][s:left] = col('.')
    normal! $
    let column[s:bottom][s:right] = col('.')

    let slices = SlicesFromSelection(line_contents, column, comment_len)
    let has_comment = IsSelectionCommented(slices, comment)
    let leftmost_col = FindLeftmost(line)
    let stringofspaces = repeat(' ', leftmost_col - 1)

    " Add or remove comments as needed
    if has_comment[s:top][s:start] && has_comment[s:bottom][s:end]
        execute "normal! " . line[s:top] . "gg"
        if has_comment[s:top][s:start]
          call RemoveStartComment(comment_len[s:start])
          normal! ^
          let current_line = getline('.')
          if current_line[column[s:top][s:left] - 1] == " "
            normal! hx
          endif
        endif
        call RemoveSpacesIfBlank()
        execute "normal! " . line[s:bottom] . "gg"
        if has_comment[s:bottom][s:end]
          call RemoveEndComment(comment_len[s:end])
          normal! $
          let current_line = getline('.')
          if current_line[col('.') - 1]  == " "
            normal! x
          endif
        endif
        call RemoveSpacesIfBlank()
    else
      if !has_comment[s:top][s:start] && line_contents[s:top] !~ '^\s*$'
        execute "normal! " . line[s:top] . "gg"
        call PlaceComment(column[s:top][s:left], comment[s:start] . " ")
      endif
      if !has_comment[s:bottom][s:end] && line_contents[s:bottom] !~ '^\s*$'
        execute "normal! " . line[s:bottom] . "gg"
        call AppendComment(" " . comment[s:end])
      endif
      if !has_comment[s:top][s:start] && line_contents[s:top] =~ '^\s*$'
        execute "normal! " . line[s:top] . "gg"
        call RemoveSpacesIfBlank()
        execute "normal! 0i" . stringofspaces
        call AppendComment(comment[s:start])
      endif
      if !has_comment[s:bottom][s:end] && line_contents[s:bottom] =~ '^\s*$'
        execute "normal! " . line[s:bottom] . "gg"
        call RemoveSpacesIfBlank()
        execute "normal! 0i" . stringofspaces
        call AppendComment(comment[s:end])
      endif
    endif
  endif
  
  if !paste
    set nopaste
  endif

endfunction

vnoremap <silent> <Space> :<C-u>call VisualModeComment()<CR>$

function SingleLineComment()

  let comment = CommentList()
  if comment[s:start] == ""
    return
  endif

  let comment_len = [len(comment[s:start]), len(comment[s:end])]
  let current_line = getline('.')

  let paste = &paste
  set paste

  " If current line isn't blank (empty or composed of spaces)
  if current_line !~ '^\s*$'
    let column = [0,0]
    let original_pos = virtcol('.') " using virtcol here in case of digraphs
    normal! ^
    let column[s:left] = col('.')
    normal! $
    let column[s:right] = col('.')

    let slices = SlicesFromLine(current_line, column, comment_len)
    let has_comment = IsLineCommented(slices, comment)

    " Add or remove comment and reposition as needed:
    if has_comment[s:start] || has_comment[s:end]
      let extra_space = 0
      if has_comment[s:start]
        call RemoveStartComment(comment_len[s:start])
        normal! ^
        let current_line = getline('.')
        if current_line[column[s:left] - 1] == " "
          normal! hx
          let extra_space = 1
        endif
        call RemoveSpacesIfBlank()
      endif
      if has_comment[s:end]
        call RemoveEndComment(comment_len[s:end])
        normal! $
        let current_line = getline('.')
        if current_line[col('.') - 1]  == " "
          normal! x
        endif
        call RemoveSpacesIfBlank()
      endif
      call RepositionAfterRemove(original_pos, column[s:left], comment_len[s:start] + extra_space)
    else
      call PlaceComment(column[s:left], comment[s:start] . " ")
      if comment[s:end] != ""
        call AppendComment(" " . comment[s:end])
      endif
      call RepositionAfterAdd(original_pos, column[s:left], comment_len[s:start] + 1)
    endif
  endif

  if !paste
    set nopaste
  endif

endfunction

nnoremap <silent> <Space> :call SingleLineComment()<CR>
