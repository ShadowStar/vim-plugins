" Vim color file:  colorful256.vim
" Last Change: 03 Oct, 2007
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

if &t_Co != 256 && ! has("gui_running")
  echomsg ""
  echomsg "colors not loaded first please set t_Co=256 in your .vimrc"
  echomsg ""
  finish
endif

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "default256"

  hi SpecialKey term=bold ctermfg=4 guifg=Blue
  hi NonText term=bold ctermfg=12 gui=bold guifg=Blue
  hi Directory term=bold ctermfg=4 guifg=Blue
  hi ErrorMsg term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
  hi IncSearch term=reverse cterm=reverse gui=reverse
  hi Search term=reverse ctermbg=11 guibg=Yellow
  hi MoreMsg term=bold ctermfg=2 gui=bold guifg=SeaGreen
  hi ModeMsg term=bold cterm=bold gui=bold
  hi LineNr term=underline ctermfg=130 guifg=Brown
  hi Question term=standout ctermfg=2 gui=bold guifg=SeaGreen
  hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse
  hi StatusLineNC term=reverse cterm=reverse gui=reverse
  hi VertSplit term=reverse cterm=reverse gui=reverse
  hi Title term=bold ctermfg=5 gui=bold guifg=Magenta
  hi Visual term=reverse ctermbg=7 guibg=LightGrey
  hi WarningMsg term=standout ctermfg=1 guifg=Red
  hi WildMenu term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
  hi Folded term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=LightGrey
  hi FoldColumn term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey
  hi DiffAdd term=bold ctermbg=81 guibg=LightBlue
  hi DiffChange term=bold ctermbg=225 guibg=LightMagenta
  hi DiffDelete term=bold ctermfg=12 ctermbg=159 gui=bold guifg=Blue guibg=LightCyan
  hi DiffText term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
  hi SignColumn term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey
  hi SpellBad term=reverse ctermbg=224 gui=undercurl guisp=Red
  hi SpellCap term=reverse ctermbg=81 gui=undercurl guisp=Blue
  hi SpellRare term=reverse ctermbg=225 gui=undercurl guisp=Magenta
  hi SpellLocal term=underline ctermbg=14 gui=undercurl guisp=DarkCyan
  hi Pmenu ctermbg=225 guibg=LightMagenta
  hi PmenuSel ctermbg=7 guibg=Grey
  hi PmenuSbar ctermbg=248 guibg=Grey
  hi PmenuThumb cterm=reverse gui=reverse
  hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=LightGrey
  hi TabLineSel term=bold cterm=bold gui=bold
  hi TabLineFill term=reverse cterm=reverse gui=reverse
  hi CursorColumn term=reverse ctermbg=7 guibg=Grey90
  hi CursorLine term=underline cterm=underline guibg=Grey90
  hi ColorColumn term=reverse ctermbg=224 guibg=LightRed
  hi MatchParen term=reverse ctermbg=14 guibg=Cyan
  hi Comment term=bold ctermfg=4 guifg=Blue
  hi Constant term=underline ctermfg=1 guifg=Magenta
  hi Special term=bold ctermfg=5 guifg=SlateBlue
  hi Identifier term=underline ctermfg=6 guifg=DarkCyan
  hi Statement term=bold ctermfg=130 gui=bold guifg=Brown
  hi PreProc term=underline ctermfg=5 guifg=Purple
  hi Type term=underline ctermfg=2 gui=bold guifg=SeaGreen
  hi Underlined term=underline cterm=underline ctermfg=5 gui=underline guifg=SlateBlue
  hi Ignore ctermfg=15 guifg=bg
  hi Error term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
  hi Todo term=standout ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
  hi ExtraWhitespace ctermbg=9 guibg=red

