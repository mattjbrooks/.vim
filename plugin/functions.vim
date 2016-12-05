" Functions to source from vimrc.d
" ================================

let s:pathToFuncs = "~/.vim/vimrc.d/"

let s:funcsToSource = ["statusline.vim",
                      \"python.vim",
                      \"continuation.vim",
                      \"fakeCapsLock.vim",
                      \"toggleClipboard.vim",
                      \"toggleNERDTree.vim",
                      \"toggleDot.vim",
                      \"toggleHyphen.vim",
                      \"numbering.vim",
                      \"execOnReturn.vim",
                      \"indentation.vim",
                      \"completion.vim",
                      \"autoComment.vim",
                      \"tmux.vim"]

function SourceFuncs()
  let numOfFuncs = len(s:funcsToSource)
  let currentFunc = 0
  while currentFunc < numOfFuncs
    execute "source " . s:pathToFuncs . s:funcsToSource[currentFunc]
    let currentFunc = currentFunc + 1
  endwhile
  return ''
endfunction

call SourceFuncs()
