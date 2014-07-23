" Vim color file:  colorful256.vim
" Last Change:  07/23/14 18:33:08
" License: public domain
" Maintainer:: Jagpreet<jagpreetc AT gmail DOT com>
"
" for a 256 color capable terminal
" "{{{
" You must set t_Co=256 before calling this colorscheme
"
" Color numbers (0-255) see:
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
"
" Added gui colors
"

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "shadowstar"

hi Normal term=none cterm=none gui=none
hi SpecialKey term=bold ctermfg=4 guifg=Blue
hi NonText term=bold cterm=bold ctermfg=4 gui=bold guifg=Blue
hi Directory term=bold ctermfg=4 guifg=Blue
hi ErrorMsg term=standout cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
hi IncSearch term=reverse cterm=bold,reverse gui=reverse
hi Search term=reverse cterm=bold ctermfg=0 ctermbg=3 guibg=Yellow
hi MoreMsg term=bold ctermfg=2 gui=bold guifg=Green
hi ModeMsg term=bold cterm=bold gui=bold
hi LineNr term=underline ctermfg=3 guifg=Brown
hi Question term=standout ctermfg=2 gui=bold guifg=Green
hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=reverse gui=reverse
hi Title term=bold ctermfg=5 gui=bold guifg=Magenta
hi Visual term=reverse cterm=reverse guibg=Grey
hi WarningMsg term=standout ctermfg=1 guifg=Red
hi WildMenu term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi Folded term=standout ctermfg=4 ctermbg=7 guifg=Blue guibg=Grey
hi FoldColumn term=standout ctermfg=4 ctermbg=7 guifg=Blue guibg=Grey
hi DiffAdd term=bold ctermbg=4 guibg=Blue
hi DiffChange term=bold ctermbg=5 guibg=Magenta
hi DiffDelete term=bold cterm=bold ctermfg=4 ctermbg=6 gui=bold guifg=Blue guibg=Cyan
hi DiffText term=reverse cterm=bold ctermbg=1 gui=bold guibg=Red
hi SignColumn term=standout ctermfg=4 ctermbg=7 guifg=Blue guibg=Grey
hi SpellBad term=reverse ctermbg=1 gui=undercurl guisp=Red
hi SpellCap term=reverse ctermbg=4 gui=undercurl guisp=Blue
hi SpellRare term=reverse ctermbg=5 gui=undercurl guisp=Magenta
hi SpellLocal term=underline ctermbg=6 gui=undercurl guisp=Cyan
hi Pmenu ctermbg=5 guibg=Magenta
hi PmenuSel ctermbg=7 guibg=Grey
hi PmenuSbar ctermbg=7 guibg=Grey
hi PmenuThumb cterm=reverse gui=reverse
hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=Grey
hi TabLineSel term=bold cterm=bold gui=bold
hi TabLineFill term=reverse cterm=reverse gui=reverse
hi CursorColumn term=reverse ctermbg=7 guibg=Grey
hi CursorLine term=underline cterm=underline guibg=Grey
hi ColorColumn term=reverse,bold cterm=reverse,bold ctermbg=9 guibg=Red
hi MatchParen term=reverse ctermbg=6 guibg=Cyan
hi Comment term=bold cterm=bold ctermfg=4 guifg=Blue
hi Constant term=underline ctermfg=1 guifg=Magenta
hi Special term=bold ctermfg=5 guifg=Blue
hi Identifier term=underline ctermfg=6 guifg=Cyan
hi Statement term=bold ctermfg=3 gui=bold guifg=Brown
hi PreProc term=underline cterm=bold ctermfg=5 guifg=Purple
hi Type term=underline ctermfg=2 gui=bold guifg=Green
hi Underlined term=underline cterm=underline ctermfg=5 gui=underline guifg=Blue
hi Ignore cterm=bold ctermfg=7 guifg=bg
hi Error term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
hi Todo term=standout cterm=bold ctermfg=0 ctermbg=3 guifg=Blue guibg=Yellow
hi ExtraWhitespace term=standout ctermbg=1 guibg=Red

runtime! syntax/style.vim

