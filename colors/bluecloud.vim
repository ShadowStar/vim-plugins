" Vim color file
" Author: Edwin Pujols <edwinpm5@gmail.com>
" Last Change: 2013 Jul 24
"

hi clear

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="bluecloud"

hi ColorColumn                   guibg=#102544

hi LineNr          guifg=bg      guibg=#102544
hi NonText         guifg=bg      guibg=#102544
hi Normal          guifg=#D0D0D0 guibg=#204A87
hi Comment         guifg=#000000
hi Boolean         guifg=#87F0FF
hi Character       guifg=#73D216
hi Number          guifg=#87DD40
hi String          guifg=#87FD40
hi Conditional     guifg=#00FAFF               gui=bold
hi Constant        guifg=#87FD40               gui=bold
hi Cursor          guifg=#000000 guibg=#F0F0F0
hi CursorLine      guibg=#275BA6
hi CursorColumn    guibg=#275BA6

hi Debug           guifg=#BCA3A3               gui=bold
hi Define          guifg=#E4CC47
hi Delimiter       guifg=#8F8F8F
hi DiffAdd                       guibg=#13354A
hi DiffChange      guifg=#89807D guibg=#4C4745
hi DiffDelete      guifg=#960050 guibg=#1E0010
hi DiffText                      guibg=#4C4745 gui=italic,bold

hi Directory       guifg=#BFF040               gui=bold
hi Error           guifg=#960050 guibg=#1E0010
hi ErrorMsg        guifg=#FF0050 guibg=#1E0010 gui=bold
hi Exception       guifg=#FFAF20               gui=bold
hi Float           guifg=#87DD40
hi FoldColumn      guifg=#465457 guibg=#000000
hi Folded          guifg=#465457 guibg=#000000
hi Function        guifg=#EC7753
hi Identifier      guifg=#FD971F
hi Ignore          guifg=#808080 guibg=bg
hi IncSearch       guifg=#C4BE89 guibg=#000000

hi Keyword         guifg=#00C8CC               gui=bold
hi Label           guifg=#DF7AFF               gui=none
hi Macro           guifg=#C4BE89               gui=italic
hi SpecialKey      guifg=#E4CC47               gui=italic

hi MatchParen      guifg=#000000 guibg=#FD971F gui=bold
hi ModeMsg         guifg=#73D216
hi MoreMsg         guifg=#73D216
hi Operator        guifg=#A0A0F0

" complete menu
hi Pmenu           guifg=#E4CC47 guibg=#000000
hi PmenuSel        guifg=#E4CC47 guibg=#000000 gui=reverse
hi PmenuSbar                     guibg=#121212
hi PmenuThumb                    guibg=#5F6050

hi PreCondit       guifg=#FFD000               gui=bold
hi PreProc         guifg=#FFA0A0
hi Question        guifg=#E4CC47
hi Repeat          guifg=#00FAFF               gui=bold
hi Search          guifg=#000000 guibg=#FFFF00
" marks column
hi SignColumn      guifg=#EC6753 guibg=#232526
hi SpecialChar     guifg=#DF90B8               gui=none
hi SpecialComment  guifg=#0088DB               gui=bold
hi Special         guifg=#E4CC47 guibg=bg      gui=italic
hi SpecialKey      guifg=#888A85               gui=italic
if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#F0C000 gui=undercurl
    hi SpellLocal  guisp=#FFFF00 gui=undercurl
    hi SpellRare   guisp=#00FF00 gui=undercurl
endif
hi Statement       guifg=#60FFFF               gui=bold
hi StatusLine      guifg=#00FFFF guibg=#000000 gui=none
hi StatusLineNC    guifg=#141414 guibg=#103C67
hi StorageClass    guifg=#FFA71F               gui=italic
hi Structure       guifg=#E4CC47
hi Tag             guifg=#00FAFF               gui=italic
hi Title           guifg=#FF5AF9
hi Todo            guifg=#FFFFFF guibg=#000000 gui=bold

hi Typedef         guifg=#E4CC47
hi Type            guifg=#E4CC47               gui=none
hi Underlined      guifg=fg                    gui=underline

hi VertSplit       guifg=#808080 guibg=#080808 gui=bold
hi VisualNOS                     guibg=#403D3D
hi Visual                        guibg=#132C51
hi WarningMsg      guifg=#FFD390 guibg=#333333 gui=bold
hi WildMenu        guifg=#E4CC47 guibg=#000000

