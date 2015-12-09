" Vim color file

" Modified from the default color scheme.
" (if using add: export TERM=xterm-256color or equivalent to .bashrc)

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "matts_modified_scheme"

highlight Normal ctermbg=234 ctermfg=254
highlight Comment ctermfg=036
highlight Statement ctermfg=227
highlight Identifier ctermfg=038
highlight PreProc ctermfg=blue
highlight Constant ctermfg=red
highlight Visual term=reverse ctermbg=238
highlight Special ctermfg=063
highlight Title ctermfg=255
highlight MatchParen ctermfg=none ctermbg=237 cterm=none
highlight Search ctermbg=238 ctermfg=011
highlight Type ctermfg=121
highlight Directory ctermfg=159
highlight Folded ctermfg=grey ctermbg=234
highlight TabLineFill ctermfg=238
highlight TabLine cterm=none ctermfg=250 ctermbg=238
highlight TabLineSel ctermfg=254 ctermbg=235 cterm=none
highlight Cursorline cterm=none ctermbg=none
highlight CursorLineNr ctermbg=237
highlight LineNr ctermfg=grey
highlight CursorLineNr ctermfg=grey
highlight StatusLine cterm=bold ctermfg=032 ctermbg=none
highlight StatusLineNC cterm=none ctermfg=DarkGrey ctermbg=none
highlight ColorColumn ctermbg=235

" Vertical split highlighting
highlight clear VertSplit

" Autocomplete menu
highlight Pmenu ctermbg=024
highlight Pmenuthumb ctermbg=024
highlight Pmenusel ctermbg=grey

" HTML
highlight htmlTitle ctermfg=red
highlight htmlString ctermfg=033

" Javascript
highlight javaScript ctermfg=253
