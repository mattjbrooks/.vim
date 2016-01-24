" Add highlighting for media queries
syn region cssMediaType start='(' end=')' contains=css.*Attr,css.*Prop,cssComment,cssValue.*,cssColor,cssURL,cssImportant,cssError,cssStringQ,cssStringQQ,cssFunction,cssUnicodeEscape nextgroup=cssMediaComma,cssMediaAnd,cssMediaBlock skipwhite skipnl
syn match cssMediaAnd "and" nextgroup=cssMediaType skipwhite skipnl

" Add highlighting for border-radius
syn match cssBoxProp contained "\<border\(-\(radius\)\)\=\>"
