" Vim syntax file
" Language: hexx
" Author: Richard Bentley-Green
" Revision: 18/03/2023

" Note: Syntax efficiency can be checked - ref. `:help syntime`

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = 'hexx'
syntax case match

setlocal conceallevel=2
setlocal concealcursor=nvic

" Address/offset
syn match hexxAddr '^[^ ]\+'

" Division lines in hex data for 1, 2 and 4 byte groupings
if get(g:, 'Hexx_showHexDiv', 1)
  " Division lines every 4 hex byte groupings
  syn match Conceal '\([0-9a-fA-F]\)\{2,}\( \([0-9a-fA-F]\)\{2,}\)\{3}\zs  \@!' conceal cchar=|
endif

" ASCII section of display
if exists('hexx#AsciiStartCol')
  exe "syn region hexxAscii start=\"\\%".hexx#AsciiStartCol."c\" end=\"\\%".hexx#AsciiEndCol."c\""
else
  " Fallback - shouldn't be needed (this is imperfect, hence not used generally)
  syn match hexxAscii '\(  \)\zs.*$'
endif

" --------------------------------------
" Colour definitions

" highlight default hexxAddr    cterm=bold ctermfg=106 gui=bold guifg=#87af00
" highlight default hexxAscii   ctermfg=94 ctermbg=234 guifg=#875f00 guibg=#1c1c1c

hi def link hexxAddr    poblDkGreenBold
hi def link hexxAscii   Folded

" eof

