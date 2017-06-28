"===============================================================================
"
"          File:  kconfig.vim
" 
"   Description:  Expand detection of filetype kconfig
" 
"   VIM Version:  7.0+
"        Author:  ShadowStar, <orphen.leiliu@gmail.com>
"  Organization:  Gmail
"       Version:  1.0
"       Created:  06/28/2017 13:47:32
"   Last Change:06/28/2017 13:48:31
"      Revision:  ---
"       License:  Copyright (c) 2017, Lei Liu
"===============================================================================

au BufNewFile,BufRead Config.in	setf kconfig
