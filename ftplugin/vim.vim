"===============================================================================
"
"          File:  vim.vim
"
"   Description:  Vim
"
"   VIM Version:  7.0+
"        Author:  Lei Liu (ShadowStar), liulei@jusontech.com
"  Organization:  Juson Tech
"       Version:  1.0
"       Created:  04/18/14 11:11:35
"   Last Change:  04/18/14 11:33:56
"      Revision:  ---
"       License:  Copyright (c) year 2014, Lei Liu
"===============================================================================

if exists("b:did_vim_ftplugin")
	finish
endif

let b:did_vim_ftplugin = 1

if exists("loaded_matchit")
	let s:sol = '\%(;\s*\|^\s*\)\@<='  " start of line
	let b:match_words =
	\ s:sol . 'fu\%[nction]\>:' . s:sol . 'retu\%[rn]\>:' .
	\ s:sol . 'endf\%[unction]\>,' .
	\ s:sol . '\(wh\%[ile]\|for\)\>:' . s:sol . 'brea\%[k]\>:' .
	\ s:sol . 'con\%[tinue]\>:' . s:sol . 'end\(w\%[hile]\|fo\%[r]\)\>,' .
	\ s:sol . 'if\>:' . s:sol . 'el\%[seif]\>:' . s:sol . 'en\%[dif]\>,' .
	\ s:sol . 'try\>:' . s:sol . 'cat\%[ch]\>:' .
	\ s:sol . 'fina\%[lly]\>:' . s:sol . 'endt\%[ry]\>,' .
	\ s:sol . 'aug\%[roup]\s\+\%(END\>\)\@!\S:' .
	\ s:sol . 'aug\%[roup]\s\+END\>,' . '(:)'
endif
