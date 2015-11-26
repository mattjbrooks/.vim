if exists("g:html_indent_tags") " check if g:html_indent_tags is used - changes in vim 7.4
  " HTML 5 elements to indent
  let g:html_indent_tags .= '\|article\|aside\|audio\|canvas\|datalist'
  let g:html_indent_tags .= '\|details\|embed\|figcaption\|figure\|footer'
  let g:html_indent_tags .= '\|header\|keygen\|main\|mark\|meter\|menuitem'
  let g:html_indent_tags .= '\|nav\|output\|progress\|rp\|rt\|ruby'
  let g:html_indent_tags .= '\|section\|source\|summary\|time\|video'
endif
