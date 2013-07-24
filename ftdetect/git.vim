" File:         gitignore.vim
" Description:  .gitignore plugin for Vim
" Author:       Roman Dolgushin <rd@roman-dolgushin.ru>
" URL:          https://github.com/rdolgushin/gitignore.vim

au BufNewFile,BufRead *.gitignore* setf gitignore
au BufNewFile,BufRead *.git/*/COMMIT_EDITMSG setf gitcommit

