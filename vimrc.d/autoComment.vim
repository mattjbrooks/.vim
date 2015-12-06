let s:start = 0 | let s:top = 0 | let s:left = 0 | let s:no_space = 0
let s:end = 1 | let s:bottom = 1 | let s:right = 1 | let s:added_space = 1

function CommentList()
  let comment_list = [['',''],['','']]
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
  let comment_list[s:no_space] = [start_comment, end_comment]
  let comment_list[s:added_space] = [start_comment . " ", " " . end_comment]
  return comment_list
endfunction

function CommentLen(comment)
  let comment_len = [[0,0],[0,0]]
  let comment_len[s:no_space] = [len(a:comment[s:no_space][s:start]), len(a:comment[s:no_space][s:end])]
  let comment_len[s:added_space] = [len(a:comment[s:added_space][s:start]), len(a:comment[s:added_space][s:end])]
  return comment_len
endfunction

function FindRightmost(line)
  let line_num = a:line[s:top]
  let rightmost_pos = len(getline('.'))
  while line_num <= a:line[s:bottom]
    execute "normal! " . line_num . "gg"
    let length_of_line = len(getline('.'))
    if length_of_line > rightmost_pos
      let rightmost_pos = length_of_line
    endif
    let line_num = line_num + 1
  endwhile
  return rightmost_pos
endfunction

function FindLeftmost(line, rightmost_pos)
  let line_num = a:line[s:top]
  let leftmost_col = a:rightmost_pos
  while line_num <= a:line[s:bottom]
    execute "normal! " . line_num . "gg"
    normal! ^
    let col_start = col('.')
    let current_line = getline('.')
    if col_start < leftmost_col && current_line !~ '^\s*$'
      let leftmost_col = col_start
    endif
    let line_num = line_num + 1
  endwhile
  return leftmost_col
endfunction

function CheckIfUncommented(line, position, comment)
  let line_num = a:line[s:top]
  let has_line_without_comment = 0
  while line_num <= a:line[s:bottom]
    execute "normal! " . line_num . "gg"
    let current_line = getline('.')
    let slice_of_line = current_line[(a:position[s:left]):(a:position[s:right])]
    if slice_of_line != a:comment && current_line !~ '^\s*$'
      let has_line_without_comment = 1
    endif
    let line_num = line_num + 1
  endwhile
  return has_line_without_comment
endfunction

function AddCommentStart(line_num, left_pos, comment)
  execute "normal! " . a:line_num . "gg"
  let current_line = getline('.')
  if current_line !~ '^\s*$'
    if a:left_pos == 0
      execute "normal! 0i" . a:comment
    else
      execute "normal!" . a:left_pos . "\|"
      execute "normal! a" . a:comment
    endif
  endif
endfunction

function RemoveCommentStart(line_num, position, comment, comment_length)
  execute "normal! " . a:line_num . "gg"
  let current_line = getline('.')
  let slice_of_line = current_line[(a:position[s:left]):(a:position[s:right])]
  if slice_of_line == a:comment
    normal! ^
    execute "normal! " . a:comment_length . "x"
  endif
endfunction

function RemoveSpacesIfEmpty()
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

function SlicesFromSelection(line_contents, column, comment_len)
  let slices = [[['',''],['','']],[['',''],['','']]]
  let ns = s:no_space | let s = s:added_space | let top = s:top | let bot = s:bottom

  let slices[ns][top] = SlicesFromLine(a:line_contents[top], a:column[top], a:comment_len[ns])
  let slices[ns][bot] = SlicesFromLine(a:line_contents[bot], a:column[bot], a:comment_len[ns])
  let slices[s][top] = SlicesFromLine(a:line_contents[top], a:column[top], a:comment_len[s])
  let slices[s][bot] = SlicesFromLine(a:line_contents[bot], a:column[bot], a:comment_len[s])

  return slices
endfunction

function IsSelectionCommented(slices, comment)
  let has_comment = [[['',''],['','']],[['',''],['','']]]
  let ns = s:no_space | let s = s:added_space | let top = s:top | let bot = s:bottom

  let has_comment[ns][top] = IsLineCommented(a:slices[ns][top], a:comment[ns])
  let has_comment[ns][bot] = IsLineCommented(a:slices[ns][bot], a:comment[ns])
  let has_comment[s][top] = IsLineCommented(a:slices[s][top], a:comment[s])
  let has_comment[s][bot] = IsLineCommented(a:slices[s][bot], a:comment[s])

  return has_comment
endfunction

function VisualModeComment()

  " Get a list of strings to add or remove from lines
  let comment = CommentList()
  if comment[s:no_space][s:start] == ""
    return
  endif

  " Get a list of the length of those strings
  let comment_len = CommentLen(comment)

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

  if comment[s:no_space][s:end] == ""
    " Find rightmost position
    let rightmost_pos = FindRightmost(line)

    " Find leftmost column
    let leftmost_col = FindLeftmost(line, rightmost_pos)

    " Find left and right pos where starting comment string would go
    let position = [[0, 0],[0,0]]
    let position[s:no_space][s:left] = leftmost_col - 1
    let position[s:no_space][s:right] = position[s:no_space][s:left] + comment_len[s:no_space][s:start] - 1
    let position[s:added_space][s:left] = leftmost_col - 1
    let position[s:added_space][s:right] = position[s:added_space][s:left] + comment_len[s:added_space][s:start] - 1
    
    " Check if any non-blank lines in highlighted text have no comment
    let has_line_without_comment = [0,0]
    let has_line_without_comment[s:no_space] = CheckIfUncommented(line, position[s:no_space], comment[s:no_space][s:start])
    let has_line_without_comment[s:added_space] = CheckIfUncommented(line, position[s:added_space], comment[s:added_space][s:start])

    " Add or remove comments to non blank lines
    if has_line_without_comment[s:no_space]
      let line_num = line[s:top]
      while line_num <= line[s:bottom]
        call AddCommentStart(line_num, position[s:added_space][s:left], comment[s:added_space][s:start])
        let line_num = line_num + 1
      endwhile
    else
      let line_num = line[s:top]
      while line_num <= line[s:bottom]
        if has_line_without_comment[s:added_space]
          call RemoveCommentStart(line_num, position[s:no_space], comment[s:no_space][s:start], comment_len[s:no_space][s:start])
        else
          call RemoveCommentStart(line_num, position[s:added_space], comment[s:added_space][s:start], comment_len[s:added_space][s:start])
        endif
        let line_num = line_num + 1
      endwhile
    endif
  else " if comment[s:no_space][s:end] != ''
    " (ie if the current comment type has an end string as well as a start string)
    let line_contents = ['','']
    let column = [[0,0],[0,0]]
    let has_comment = [[['',''],['','']],[['',''],['','']]]

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
    let rightmost_pos = FindRightmost(line)
    let leftmost_col = FindLeftmost(line, rightmost_pos)
    let stringofspaces = repeat(' ', leftmost_col - 1)

    " Add or remove comments as needed
    if has_comment[s:no_space][s:top][s:start] && has_comment[s:no_space][s:bottom][s:end]
        execute "normal! " . line[s:top] . "gg"
        if has_comment[s:added_space][s:top][s:start]
          call RemoveStartComment(comment_len[s:added_space][s:start])
        else
          call RemoveStartComment(comment_len[s:no_space][s:start])
        endif
        call RemoveSpacesIfEmpty()
        execute "normal! " . line[s:bottom] . "gg"
        if has_comment[s:added_space][s:bottom][s:end]
          call RemoveEndComment(comment_len[s:added_space][s:end])
        else
          call RemoveEndComment(comment_len[s:no_space][s:end])
        endif
        call RemoveSpacesIfEmpty()
    else
      if !has_comment[s:no_space][s:top][s:start] && line_contents[s:top] !~ '^\s*$'
        execute "normal! " . line[s:top] . "gg"
        call PlaceComment(column[s:top][s:left], comment[s:added_space][s:start])
      endif
      if !has_comment[s:no_space][s:bottom][s:end] && line_contents[s:bottom] !~ '^\s*$'
        execute "normal! " . line[s:bottom] . "gg"
        call AppendComment(comment[s:added_space][s:end])
      endif
      if !has_comment[s:no_space][s:top][s:start] && line_contents[s:top] =~ '^\s*$'
        execute "normal! " . line[s:top] . "gg"
        call RemoveSpacesIfEmpty()
        execute "normal! 0i" . stringofspaces
        call AppendComment(comment[s:no_space][s:start])
      endif
      if !has_comment[s:no_space][s:bottom][s:end] && line_contents[s:bottom] =~ '^\s*$'
        execute "normal! " . line[s:bottom] . "gg"
        call RemoveSpacesIfEmpty()
        execute "normal! 0i" . stringofspaces
        call AppendComment(comment[s:no_space][s:end])
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
  if comment[s:no_space][s:start] == ""
    return
  endif

  let comment_len = CommentLen(comment)

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

    let slices = [['',''],['','']]
    let has_comment = [['',''],['','']]

    let slices[s:no_space] = SlicesFromLine(current_line, column, comment_len[s:no_space])
    let slices[s:added_space] = SlicesFromLine(current_line, column, comment_len[s:added_space])

    let has_comment[s:no_space] = IsLineCommented(slices[s:no_space], comment[s:no_space])
    let has_comment[s:added_space] = IsLineCommented(slices[s:added_space], comment[s:added_space])

    " Add or remove comment and reposition as needed:
    if has_comment[s:no_space][s:start] || has_comment[s:no_space][s:end]
      let extra_space = 0
      if has_comment[s:no_space][s:start]
        if has_comment[s:added_space][s:start]
          call RemoveStartComment(comment_len[s:added_space][s:start])
          let extra_space = 1
        else
          call RemoveStartComment(comment_len[s:no_space][s:start])
        endif
        call RemoveSpacesIfEmpty()
      endif
      if has_comment[s:no_space][s:end]
        if has_comment[s:added_space][s:end]
          call RemoveEndComment(comment_len[s:added_space][s:end])
        else
          call RemoveEndComment(comment_len[s:no_space][s:end])
        endif
        call RemoveSpacesIfEmpty()
      endif
      call RepositionAfterRemove(original_pos, column[s:left], comment_len[s:no_space][s:start] + extra_space)
    else
      call PlaceComment(column[s:left], comment[s:added_space][s:start])
      if comment[s:no_space][s:end] != ""
        call AppendComment(comment[s:added_space][s:end])
      endif
      call RepositionAfterAdd(original_pos, column[s:left], comment_len[s:added_space][s:start])
    endif
  endif

  if !paste
    set nopaste
  endif

endfunction

nnoremap <silent> <Space> :call SingleLineComment()<CR>