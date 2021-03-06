" Vim color file:  colorful256.vim
" Last Change:  07/23/14 18:30:15
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

if &t_Co < 16
  echomsg ""
  echomsg "Colors NOT loaded when t_Co less than 16"
  echomsg ""
  finish
endif

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "shadowstar-light"

if &t_Co == 256
  hi Normal term=none cterm=none gui=none
  hi SpecialKey term=bold ctermfg=12 guifg=Blue
  hi NonText term=bold cterm=bold ctermfg=12 gui=bold guifg=Blue
  hi Directory term=bold ctermfg=12 guifg=Blue
  hi ErrorMsg term=standout cterm=bold ctermfg=15 ctermbg=9 guifg=White guibg=Red
  hi IncSearch term=reverse cterm=bold,reverse gui=reverse
  hi Search term=reverse cterm=bold ctermfg=0 ctermbg=11 guibg=Yellow
  hi MoreMsg term=bold ctermfg=10 gui=bold guifg=Green
  hi ModeMsg term=bold cterm=bold gui=bold
  hi LineNr term=underline ctermfg=130 guifg=Brown
  hi Question term=standout ctermfg=10 gui=bold guifg=Green
  hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse
  hi StatusLineNC term=reverse cterm=reverse gui=reverse
  hi VertSplit term=reverse cterm=reverse gui=reverse
  hi Title term=bold ctermfg=13 gui=bold guifg=Magenta
  hi Visual term=reverse cterm=reverse ctermbg=238 guibg=Grey
  hi WarningMsg term=standout ctermfg=9 guifg=Red
  hi WildMenu term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
  hi Folded term=standout ctermfg=12 ctermbg=238 guifg=Blue guibg=Grey
  hi FoldColumn term=standout ctermfg=12 ctermbg=238 guifg=Blue guibg=Grey
  hi DiffAdd term=bold ctermbg=12 guibg=Blue
  hi DiffChange term=bold ctermbg=13 guibg=Magenta
  hi DiffDelete term=bold cterm=bold ctermfg=12 ctermbg=14 gui=bold guifg=Blue guibg=Cyan
  hi DiffText term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
  hi SignColumn term=standout ctermfg=12 ctermbg=238 guifg=Blue guibg=Grey
  hi SpellBad term=reverse ctermbg=9 gui=undercurl guisp=Red
  hi SpellCap term=reverse ctermbg=12 gui=undercurl guisp=Blue
  hi SpellRare term=reverse ctermbg=13 gui=undercurl guisp=Magenta
  hi SpellLocal term=underline ctermbg=14 gui=undercurl guisp=Cyan
  hi Pmenu ctermbg=13 guibg=Magenta
  hi PmenuSel ctermbg=238 guibg=Grey
  hi PmenuSbar ctermbg=238 guibg=Grey
  hi PmenuThumb cterm=reverse gui=reverse
  hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=238 gui=underline guibg=Grey
  hi TabLineSel term=bold cterm=bold gui=bold
  hi TabLineFill term=reverse cterm=reverse gui=reverse
  hi CursorColumn term=reverse ctermbg=238 guibg=Grey
  hi CursorLine term=underline cterm=underline guibg=Grey
  hi ColorColumn term=reverse,bold cterm=reverse,bold ctermbg=9 guibg=Red
  hi MatchParen term=reverse ctermbg=14 guibg=Cyan
  hi Comment term=bold cterm=bold ctermfg=12 guifg=Blue
  hi Constant term=underline ctermfg=9 guifg=Magenta
  hi Special term=bold ctermfg=13 guifg=Blue
  hi Identifier term=underline ctermfg=14 guifg=Cyan
  hi Statement term=bold ctermfg=11 gui=bold guifg=Brown
  hi PreProc term=underline cterm=bold ctermfg=13 guifg=Purple
  hi Type term=underline ctermfg=10 gui=bold guifg=Green
  hi Underlined term=underline cterm=underline ctermfg=13 gui=underline guifg=Blue
  hi Ignore cterm=bold ctermfg=15 guifg=bg
  hi Error term=reverse cterm=bold ctermfg=15 ctermbg=9 guifg=White guibg=Red
  hi Todo term=standout cterm=bold ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
  hi ExtraWhitespace term=standout ctermbg=9 guibg=Red
else
  hi Normal term=none cterm=none gui=none
  hi SpecialKey term=bold ctermfg=12 guifg=Blue
  hi NonText term=bold cterm=bold ctermfg=12 gui=bold guifg=Blue
  hi Directory term=bold ctermfg=12 guifg=Blue
  hi ErrorMsg term=standout cterm=bold ctermfg=15 ctermbg=9 guifg=White guibg=Red
  hi IncSearch term=reverse cterm=bold,reverse gui=reverse
  hi Search term=reverse cterm=bold ctermfg=0 ctermbg=11 guibg=Yellow
  hi MoreMsg term=bold ctermfg=10 gui=bold guifg=Green
  hi ModeMsg term=bold cterm=bold gui=bold
  hi LineNr term=underline ctermfg=11 guifg=Brown
  hi Question term=standout ctermfg=10 gui=bold guifg=Green
  hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse
  hi StatusLineNC term=reverse cterm=reverse gui=reverse
  hi VertSplit term=reverse cterm=reverse gui=reverse
  hi Title term=bold ctermfg=13 gui=bold guifg=Magenta
  hi Visual term=reverse cterm=reverse ctermbg=7 guibg=Grey
  hi WarningMsg term=standout ctermfg=9 guifg=Red
  hi WildMenu term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
  hi Folded term=standout ctermfg=12 ctermbg=7 guifg=Blue guibg=Grey
  hi FoldColumn term=standout ctermfg=12 ctermbg=7 guifg=Blue guibg=Grey
  hi DiffAdd term=bold ctermbg=12 guibg=Blue
  hi DiffChange term=bold ctermbg=13 guibg=Magenta
  hi DiffDelete term=bold cterm=bold ctermfg=12 ctermbg=14 gui=bold guifg=Blue guibg=Cyan
  hi DiffText term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
  hi SignColumn term=standout ctermfg=12 ctermbg=7 guifg=Blue guibg=Grey
  hi SpellBad term=reverse ctermbg=9 gui=undercurl guisp=Red
  hi SpellCap term=reverse ctermbg=12 gui=undercurl guisp=Blue
  hi SpellRare term=reverse ctermbg=13 gui=undercurl guisp=Magenta
  hi SpellLocal term=underline ctermbg=14 gui=undercurl guisp=Cyan
  hi Pmenu ctermbg=13 guibg=Magenta
  hi PmenuSel ctermbg=7 guibg=Grey
  hi PmenuSbar ctermbg=7 guibg=Grey
  hi PmenuThumb cterm=reverse gui=reverse
  hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=Grey
  hi TabLineSel term=bold cterm=bold gui=bold
  hi TabLineFill term=reverse cterm=reverse gui=reverse
  hi CursorColumn term=reverse ctermbg=7 guibg=Grey
  hi CursorLine term=underline cterm=underline guibg=Grey
  hi ColorColumn term=reverse,bold cterm=reverse,bold ctermbg=9 guibg=Red
  hi MatchParen term=reverse ctermbg=14 guibg=Cyan
  hi Comment term=bold cterm=bold ctermfg=12 guifg=Blue
  hi Constant term=underline ctermfg=9 guifg=Magenta
  hi Special term=bold ctermfg=13 guifg=Blue
  hi Identifier term=underline ctermfg=14 guifg=Cyan
  hi Statement term=bold ctermfg=11 gui=bold guifg=Brown
  hi PreProc term=underline cterm=bold ctermfg=13 guifg=Purple
  hi Type term=underline ctermfg=10 gui=bold guifg=Green
  hi Underlined term=underline cterm=underline ctermfg=13 gui=underline guifg=Blue
  hi Ignore cterm=bold ctermfg=15 guifg=bg
  hi Error term=reverse cterm=bold ctermfg=15 ctermbg=9 guifg=White guibg=Red
  hi Todo term=standout cterm=bold ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
  hi ExtraWhitespace term=standout ctermbg=9 guibg=Red
endif

runtime! syntax/style.vim

