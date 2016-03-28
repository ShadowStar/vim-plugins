" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  ZSH
"     Plugin :  zsh.vim
" Maintainer :  ShadowStar <orphen.leiliu@gmail.com>
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
"
if exists("b:did_zsh_ftplugin")
  finish
endif
let b:did_zsh_ftplugin = 1

if exists("loaded_matchit")
    let s:sol = '\%(;\s*\|^\s*\)\@<='  " start of line
    let b:match_words =
    \ s:sol.'if\>:' . s:sol.'elif\>:' . s:sol.'else\>:' . s:sol. 'fi\>,' .
    \ s:sol.'\%(for\|while\|until\)\>:' . s:sol. 'done\>,' .
    \ s:sol.'case\>:' . s:sol. 'esac\>'
endif

