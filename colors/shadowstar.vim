" Vim color file:  colorful256.vim
" Last Change: 08/23/2024 17:39:41
" License: public domain
" Maintainer: ShadowStar, <orphen.leiliu@gmail.com>
"
" for a 256 color capable terminal
" "{{{
" You must set t_Co=256 before calling this colorscheme
"
" Color numbers (0-255) see:
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "shadowstar"

hi Normal term=none cterm=none
hi SpecialKey term=bold ctermfg=4
hi NonText term=bold cterm=bold ctermfg=4
hi Directory term=bold ctermfg=4
hi ErrorMsg term=standout cterm=bold ctermfg=7 ctermbg=1
hi IncSearch term=reverse cterm=bold,reverse
hi Search term=reverse cterm=bold ctermfg=0 ctermbg=3
hi MoreMsg term=bold ctermfg=2
hi ModeMsg term=bold cterm=bold
hi LineNr term=underline ctermfg=3
hi Question term=standout ctermfg=2
hi StatusLine term=bold,reverse cterm=bold,reverse
hi StatusLineNC term=reverse cterm=reverse
hi VertSplit term=reverse cterm=reverse ctermfg=8
hi Title term=bold ctermfg=5
hi Visual term=reverse cterm=reverse
hi WarningMsg term=standout ctermfg=1
hi WildMenu term=standout ctermfg=0 ctermbg=3
hi Folded term=standout ctermfg=4 ctermbg=7
hi FoldColumn term=standout ctermfg=4 ctermbg=7
hi DiffAdd term=bold ctermbg=4
hi DiffChange term=bold ctermbg=5
hi DiffDelete term=bold cterm=bold ctermfg=4 ctermbg=6
hi DiffText term=reverse cterm=bold ctermbg=1
hi SignColumn term=standout ctermfg=4 ctermbg=7
hi SpellBad term=reverse ctermbg=1
hi SpellCap term=reverse ctermbg=4
hi SpellRare term=reverse ctermbg=5
hi SpellLocal term=underline ctermbg=6
hi Pmenu ctermbg=5
hi PmenuSel ctermbg=7
hi PmenuSbar ctermbg=7
hi PmenuThumb cterm=reverse
hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=7
hi TabLineSel term=bold cterm=bold
hi TabLineFill term=reverse cterm=reverse
hi CursorColumn term=reverse ctermbg=7
hi CursorLine term=underline cterm=underline
hi ColorColumn term=reverse,bold cterm=reverse,bold ctermfg=7
hi MatchParen term=reverse ctermbg=6
hi Comment term=bold cterm=bold ctermfg=4
hi Constant term=underline ctermfg=1
hi Special term=bold ctermfg=5
hi Identifier term=underline ctermfg=6
hi Statement term=bold ctermfg=3
hi PreProc term=underline cterm=bold ctermfg=5
hi Type term=underline ctermfg=2
hi Underlined term=underline cterm=underline ctermfg=5
hi Ignore cterm=bold ctermfg=7
hi Error term=reverse cterm=bold ctermfg=7 ctermbg=1
hi Todo term=standout cterm=bold ctermfg=0 ctermbg=3
hi ExtraWhitespace term=standout ctermbg=1

