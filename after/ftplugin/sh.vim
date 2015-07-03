
if exists("b:did_sh_ftplugin")
	finish
endif

let b:did_sh_ftplugin = 1

if exists("loaded_matchit")
    let s:sol = '\%(;\s*\|^\s*\)\@<='  " start of line
    let b:match_words =
    \ s:sol.'if\>:' . s:sol.'elif\>:' . s:sol.'else\>:' . s:sol. 'fi\>,' .
    \ s:sol.'\%(for\|while\|until\)\>:' . s:sol. 'done\>,' .
    \ s:sol.'case\>:' . s:sol. 'esac\>'
endif
