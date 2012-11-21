" Vim syntax support file
" Maintainer:	ShadowStar <orphen.leiliu@gmail.com>
" Last Change:	2012 Nov 21

" This file sets up the default methods for highlighting.

let color_list = ["Black", "Red", "Green", "Gray", "Yellow", "Blue", "Magenta", "Cyan", "White"]

" Many terminals can only use six different colors (plus black and white).
" Therefore the number of colors used is kept low. It doesn't look nice with
" too many colors anyway.
" Careful with "cterm=bold", it changes the color to bright for some terminals.
" There are two sets of defaults: for a dark and a light background.
for i in color_list
    execute 'hi def ' . i . ' term=NONE cterm=NONE ctermfg=' . i . ' ctermbg=NONE'
    execute 'hi def ' . i . 'U term=underline cterm=underline ctermfg=' . i . ' ctermbg=NONE'
    execute 'hi def ' . i . 'B term=bold cterm=bold ctermfg=' . i . ' ctermbg=NONE'
    if &background == "dark"
      if i == "White"
        execute 'hi def ' . i . 'R term=reverse cterm=NONE ctermfg=Black ctermbg=' . i
      else
        execute 'hi def ' . i . 'R term=reverse cterm=NONE ctermfg=White ctermbg=' . i
      endif
    else
      if i == "Black"
        execute 'hi def ' . i . 'R term=reverse cterm=NONE ctermfg=White ctermbg=' . i
      else
        execute 'hi def ' . i . 'R term=reverse cterm=NONE ctermfg=Black ctermbg=' . i
      endif
    endif
endfor

