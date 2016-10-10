" Vim syntax support file
" Maintainer: ShadowStar, <orphen.leiliu@gmail.com>
" Last Change: 09/22/2016 17:40:48

" This file sets up the default methods for highlighting.

let color_list = {1: 'Red', 2: 'Green', 3: 'Yellow', 4: 'Blue', 5: 'Magenta', 6: 'Cyan', 7: 'White'}

" Many terminals can only use six different colors (plus black and white).
" Therefore the number of colors used is kept low. It doesn't look nice with
" too many colors anyway.
" Careful with "cterm=bold", it changes the color to bright for some terminals.
" There are two sets of defaults: for a dark and a light background.

function! s:SetColor(v, k)
  execute 'hi ' . a:v . ' term=none cterm=none ctermfg=' . a:k . ' ctermbg=none'
  execute 'hi ' . a:v . 'U term=underline cterm=underline ctermfg=' . a:k . ' ctermbg=none'
  execute 'hi ' . a:v . 'R term=reverse cterm=reverse ctermfg=' . a:k ' ctermbg=none'
  execute 'hi ' . a:v . 'B term=bold cterm=bold ctermfg=' . a:k . ' ctermbg=none'
  execute 'hi ' . a:v . 'UB term=underline,bold cterm=underline,bold ctermfg=' . a:k . ' ctermbg=none'
  execute 'hi ' . a:v . 'RB term=reverse,bold cterm=reverse,bold ctermfg=' . a:k ' ctermbg=none'
endfun

call s:SetColor('Black', '0')

for [key, value] in items(color_list)
  call s:SetColor(value, key)
  if &t_Co >= 16
    call s:SetColor('Light' . value, (key + 8))
  endif
endfor

if &t_Co >= 16
  call s:SetColor('Grey', '8')
  if &t_Co == 256
    call s:SetColor('Brown', '130')
  endif
endif

