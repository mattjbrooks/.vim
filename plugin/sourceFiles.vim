" Files to source from vimrc.d
" ============================

let s:path = "~/.vim/vimrc.d/"

let s:fileList = ["execOnReturn.vim",
                 \"statusline.vim",
                 \"python.vim",
                 \"continuation.vim",
                 \"fakeCapsLock.vim",
                 \"toggleClipboard.vim",
                 \"toggleNERDTree.vim",
                 \"toggleDot.vim",
                 \"toggleHyphen.vim",
                 \"toggleSetComplete.vim",
                 \"numbering.vim",
                 \"indentation.vim",
                 \"completion.vim",
                 \"autoComment.vim",
                 \"tmux.vim",
                 \"displayColor.vim"]

for s:filename in s:fileList
  execute "source " . s:path . s:filename
endfor
