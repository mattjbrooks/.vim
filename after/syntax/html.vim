 " Modified Vim HTML syntax file based on
" http://rm.blog.br/vim/syntax/html.vim by Rodrigo Machado
" This file just adds new tags from HTML 5 
" (doesn't replace the default html.vim syntax file)
 
" HTML 5 tags
syn keyword htmlTagName contained article aside audio canvas datalist
syn keyword htmlTagName contained details embed figcaption figure footer
syn keyword htmlTagName contained header keygen main mark meter menuitem
syn keyword htmlTagName contained nav output progress rp rt ruby
syn keyword htmlTagName contained section source summary time video
 
" HTML 5 attributes
syn keyword htmlArg contained autofocus placeholder min max step
syn keyword htmlArg contained contenteditable contextmenu draggable hidden item
syn keyword htmlArg contained itemprop list subject spellcheck

syn include @htmlCss syntax/css/media-queries.vim
syn include @htmlCss syntax/css/table-border.vim
