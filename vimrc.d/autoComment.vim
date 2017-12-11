function CommentSymbols()
  let start_of_comment = ''
  let end_of_comment = ''
  if &ft == 'vim'
    let start_of_comment = '"'
  elseif &ft == 'python' || &ft == 'sh'
    let start_of_comment = "#"
  elseif &ft == 'javascript' || &ft == 'php'
    let start_of_comment = "//"
  elseif &ft =~ 'html'
    if IsScript()
      let start_of_comment = '//'
    else
      let start_of_comment = '<!--'
      let end_of_comment = '-->'
    endif
  elseif &ft == 'css'
    let start_of_comment = '/*'
    let end_of_comment = '*/'
  endif
  let symbol_dict = {'start': start_of_comment,'end': end_of_comment}
  return symbol_dict
endfunction

function IsScript()
  if !exists("*synstack")
    return 0
  else
    let syntaxlist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endif
  if len(syntaxlist) > 0 && getline('.') !~ "<script" && getline('.') !~ "<?php"
    for syntaxitem in syntaxlist
      if syntaxitem =~ "php" || syntaxitem =~ "javaScript"
        return 1
      endif
    endfor
  endif
endfunction

function FindLeftmostColumn(line)
  let line_num = a:line['top']
  while line_num <= a:line['bottom']
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
  let line_num = a:line['top']
  let slices_match_string = 1
  while line_num <= a:line['bottom']
    execute "normal! " . line_num . "gg"
    let current_line = getline('.')
    let slice_of_line = current_line[(a:position['left']):(a:position['right'])]
    if slice_of_line != a:string && current_line !~ '^\s*$'
      let slices_match_string = 0
    endif
    let line_num = line_num + 1
  endwhile
  return slices_match_string
endfunction

function ClearLineOfSpaces()
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

function RepositionAfterAdd(original_pos, left_col, symbol_length)
  if a:original_pos >= a:left_col
    " Keep position if over text when comment is added
    let new_pos = a:original_pos + a:symbol_length
    execute "normal! " . new_pos . "\|"
  else
    " Unless we were originally in the white space before the text,
    " when we want to stay where we were:
    execute "normal! " . a:original_pos . "\|"
  endif
endfunction

function RemoveStartComment(symbol_length)
  normal! ^
  execute "normal! " . a:symbol_length . "x"
endfunction

function RemoveEndComment(symbol_length)
  if a:symbol_length != 0
    normal! $
    execute "normal! " . (a:symbol_length - 1) . "h"
    execute "normal! " . a:symbol_length . "x"
  endif
endfunction

function RepositionAfterRemove(original_pos, left_col, symbol_length)
  if a:original_pos >= a:left_col + a:symbol_length
    " Keep position if over text when comment is deleted
    let new_pos = a:original_pos - a:symbol_length
    execute "normal! " . new_pos . "\|"
  else
    " Unless we were originally in the white space or the comment string
    " before the text, when we want to stay where we were:
    execute "normal! " . a:original_pos . "\|"
  endif
endfunction

function SlicesFromLine(current_line, column, symbol_len)
  let slice = {'start': '', 'end': ''}

  let left_pos = a:column['left'] - 1
  let right_pos = left_pos + a:symbol_len['start'] - 1
  let slice['start'] = a:current_line[(left_pos):(right_pos)]

  if a:symbol_len['end'] > 0
    let right_pos = a:column['right'] - 1
    let left_pos = right_pos - a:symbol_len['end'] + 1
    let slice['end'] = a:current_line[(left_pos):(right_pos)]
  endif

  return slice
endfunction

function IsLineCommented(slice, symbol_dict)
  let has_comment = {'start': 0, 'end': 0}

  if a:slice['start'] == a:symbol_dict['start']
    let has_comment['start'] = 1
  endif

  if a:symbol_dict['end'] != ""
    if a:slice['end'] == a:symbol_dict['end']
      let has_comment['end'] = 1
    endif
  endif

  return has_comment
endfunction

function SlicesFromSelection(line_contents, column, symbol_len)
  let slices = {'top': {'left': '', 'right': ''},
               \'bottom': {'left': '', 'right': ''}
               \}
  let slices['top'] = SlicesFromLine(a:line_contents['top'], a:column['top'], a:symbol_len)
  let slices['bottom'] = SlicesFromLine(a:line_contents['bottom'], a:column['bottom'], a:symbol_len)
  return slices
endfunction

function IsSelectionCommented(slices, symbol_dict)
  let has_comment = {'top': {'left': '', 'right': ''},
                    \'bottom': {'left': '', 'right': ''}
                    \}
  let has_comment['top'] = IsLineCommented(a:slices['top'], a:symbol_dict)
  let has_comment['bottom'] = IsLineCommented(a:slices['bottom'], a:symbol_dict)
  return has_comment
endfunction

function VisualModeComment()

  let symbol_dict = CommentSymbols()
  if symbol_dict['start'] == ""
    return
  endif

  let symbol_len = {'start': len(symbol_dict['start']), 'end': len(symbol_dict['end'])}

  let line = {'top': 0, 'bottom': 0}
  " Find start and end lines
  normal! \<Esc>`<
  let line['top'] = line('.')
  normal! `>
  let line['bottom'] = line('.')

  " Switch line_start and line_end if necessary
  if line['top'] > line['bottom']
    let line['bottom'] = line['top']
    let line['top'] = line('.')
  endif

  let paste = &paste
  set paste

  if symbol_dict['end'] == ""
    " Find leftmost column
    let leftmost_col = FindLeftmostColumn(line)

    " Find left and right pos where starting comment string would go
    let position = {'left': 0, 'right': 0}
    let position['left'] = leftmost_col - 1
    let position['right'] = position['left'] + symbol_len['start'] - 1
    
    " Check if any lines in highlighted text have no comment, ignoring
    " lines which are empty or consist only of spaces
    let all_commented = CheckForString(line, position, symbol_dict['start'])

    " Add or remove comments to highlighted text as needed
    if all_commented == 0
      let line_num = line['top']
      while line_num <= line['bottom']
        execute "normal! " . line_num . "gg"
        let current_line = getline('.')
        if current_line !~ '^\s*$'
          call PlaceComment(leftmost_col, symbol_dict['start'] . " ")
        endif
        let line_num = line_num + 1
      endwhile
    else
      let line_num = line['top']
      while line_num <= line['bottom']
        execute "normal! " . line_num . "gg"
        let current_line = getline('.')
        let slice_of_line = current_line[(position['left']):(position['right'])]
        if slice_of_line == symbol_dict['start']
          call RemoveStartComment(symbol_len['start'])
        endif
        let line_num = line_num + 1
      endwhile
      let position['right'] = position['left']
      let all_have_space = CheckForString(line, position, " ")
      let line_num = line['top']
      if all_have_space
        while line_num <= line['bottom']
          execute "normal! " . line_num . "gg"
          normal! ^hx
          let line_num = line_num + 1
        endwhile
      endif
    endif
  else " if symbol_dict['end'] != ''
    " (i.e. if the comment needs an end string as well as a start string)
    let line_contents = {'top': '','bottom': ''}
    let column = {'top': {'left': '', 'right': ''},
                 \'bottom': {'left': '', 'right': ''}
                 \}
    execute "normal! " . line['top'] . "gg"
    let line_contents['top'] = getline('.')
    normal! ^
    let column['top']['left'] = col('.')
    normal! $
    let column['top']['right'] = col('.')

    execute "normal! " . line['bottom'] . "gg"
    let line_contents['bottom'] = getline('.')
    normal! ^
    let column['bottom']['left'] = col('.')
    normal! $
    let column['bottom']['right'] = col('.')

    let slices = SlicesFromSelection(line_contents, column, symbol_len)
    let has_comment = IsSelectionCommented(slices, symbol_dict)
    let leftmost_col = FindLeftmostColumn(line)
    let stringofspaces = repeat(' ', leftmost_col - 1)

    " Add or remove comments as needed
    if has_comment['top']['start'] && has_comment['bottom']['end']
        execute "normal! " . line['top'] . "gg"
        if has_comment['top']['start']
          call RemoveStartComment(symbol_len['start'])
          normal! ^
          let current_line = getline('.')
          if current_line[column['top']['left'] - 1] == " "
            normal! hx
          endif
        endif
        call ClearLineOfSpaces()
        execute "normal! " . line['bottom'] . "gg"
        if has_comment['bottom']['end']
          call RemoveEndComment(symbol_len['end'])
          normal! $
          let current_line = getline('.')
          if current_line[col('.') - 1]  == " "
            normal! x
          endif
        endif
        call ClearLineOfSpaces()
    else
      if !has_comment['top']['start'] && line_contents['top'] !~ '^\s*$'
        execute "normal! " . line['top'] . "gg"
        call PlaceComment(column['top']['left'], symbol_dict['start'] . " ")
      endif
      if !has_comment['bottom']['end'] && line_contents['bottom'] !~ '^\s*$'
        execute "normal! " . line['bottom'] . "gg"
        call AppendComment(" " . symbol_dict['end'])
      endif
      if !has_comment['top']['start'] && line_contents['top'] =~ '^\s*$'
        execute "normal! " . line['top'] . "gg"
        call ClearLineOfSpaces()
        execute "normal! 0i" . stringofspaces
        call AppendComment(symbol_dict['start'])
      endif
      if !has_comment['bottom']['end'] && line_contents['bottom'] =~ '^\s*$'
        execute "normal! " . line['bottom'] . "gg"
        call ClearLineOfSpaces()
        execute "normal! 0i" . stringofspaces
        call AppendComment(symbol_dict['end'])
      endif
    endif
  endif
  
  if !paste
    set nopaste
  endif

endfunction

vnoremap <silent> <Space> :<C-u>call VisualModeComment()<CR>$

function SingleLineComment()

  let symbol_dict = CommentSymbols()
  if symbol_dict['start'] == ""
    return
  endif

  let symbol_len = {'start': len(symbol_dict['start']), 'end': len(symbol_dict['end'])}
  let current_line = getline('.')

  let paste = &paste
  set paste

  " If current line isn't empty or composed of spaces
  if current_line !~ '^\s*$'
    let column = {'left': 0, 'right': 0}
    let original_pos = virtcol('.') " using virtcol here in case of digraphs
    normal! ^
    let column['left'] = col('.')
    normal! $
    let column['right'] = col('.')

    let slices = SlicesFromLine(current_line, column, symbol_len)
    let has_comment = IsLineCommented(slices, symbol_dict)

    " Add or remove comment and reposition as needed:
    if has_comment['start'] || has_comment['end']
      let extra_space = 0
      if has_comment['start']
        call RemoveStartComment(symbol_len['start'])
        normal! ^
        let current_line = getline('.')
        if current_line[column['left'] - 1] == " "
          normal! hx
          let extra_space = 1
        endif
        call ClearLineOfSpaces()
      endif
      if has_comment['end']
        call RemoveEndComment(symbol_len['end'])
        normal! $
        let current_line = getline('.')
        if current_line[col('.') - 1]  == " "
          normal! x
        endif
        call ClearLineOfSpaces()
      endif
      call RepositionAfterRemove(original_pos, column['left'], symbol_len['start'] + extra_space)
    else
      call PlaceComment(column['left'], symbol_dict['start'] . " ")
      if symbol_dict['end'] != ""
        call AppendComment(" " . symbol_dict['end'])
      endif
      call RepositionAfterAdd(original_pos, column['left'], symbol_len['start'] + 1)
    endif
  endif

  if !paste
    set nopaste
  endif

endfunction

nnoremap <silent> <Space> :call SingleLineComment()<CR>
