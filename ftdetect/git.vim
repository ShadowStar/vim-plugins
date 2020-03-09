" File:         gitignore.vim
" Description:  .gitignore plugin for Vim
" Author:       ShadowStar, <orphen.leiliu@gmail.com>
" URL:          https://github.com/rdolgushin/gitignore.vim

au BufNewFile,BufRead *.gitignore* setf gitignore
au BufNewFile,BufRead *.git/*/COMMIT_EDITMSG setf gitcommit
au BufNewFile,BufRead gitconfig* setf gitconfig
au BufNewFile,BufRead gitignore* setf gitignore

