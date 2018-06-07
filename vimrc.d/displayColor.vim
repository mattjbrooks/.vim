" Based on this post by Deltaray - http://www.climagic.org/txt/vim-color-under-cursor-function.html

function XDisplayColor(color)
  let display_command = "display -size 200x200 xc:'" . a:color . "'"
  call system(display_command)
endfunction

function ShowColorUnderCursor()
  let word_under_cursor = expand("<cword>")
  let hex_color = Hex_color()
  let rgb_color = RGB_color()
  if hex_color != ""
    call XDisplayColor(hex_color)
  elseif rgb_color != ""
    call XDisplayColor(rgb_color)
  elseif word_under_cursor != ""
    call XDisplayColor(word_under_cursor)
  endif
endfunction

function Hex_color()
  let current_word = expand("<cword>")
  let current_WORD = expand("<cWORD>")
  let hex_pattern = '[0-9a-fA-F]*'
  if len(current_word) == 3 || len(current_word) == 6
    if current_word =~ hex_pattern && current_WORD =~ '#' . current_word
      return '#' . current_word
    endif
  endif
  return ""
endfunction

function RGB_color()
  let [line, col_of_closing_bracket] = searchpos(')', 'nc', line('.'))
  if col_of_closing_bracket != 0
    let line_as_string = getline('.')
    let start_of_search = col_of_closing_bracket - 18
    let rgb_pattern = 'rgb([0-9]\{1,3}, \?[0-9]\{1,3}, \?[0-9]\{1,3})'
    let rgb_string = matchstr(line_as_string, rgb_pattern, start_of_search)
    if rgb_string != ""
      let rgb_string_start = col_of_closing_bracket - len(rgb_string) + 1
      let current_col = col('.')
      if current_col >= rgb_string_start
        return rgb_string
      endif
    endif
  endif
  return ""
endfunction

map <silent> <F6> :call ShowColorUnderCursor()<CR>
