filetype plugin on
filetype indent on
syntax on
set nocompatible

set autoindent                  " copy indent from current line
set autoread                    " read open files again when changed outside Vim
set autowrite                   " write a modified buffer on each :next , ...
set backspace=indent,eol,start  " backspacing over everything in insert mode
"set backup                      " keep a backup file
"set browsedir=current           " which directory to use for the file browser
"set complete+=k                 " scan the files given with the 'dictionary' option
set history=50                  " keep 50 lines of command line history
set hlsearch                    " highlight the last used search pattern
set incsearch                   " do incremental searching
set listchars=tab:>.,eol:\$     " strings to use in 'list' mode
"set nowrap                      " do not wrap lines
set popt=left:8pc,right:3pc     " print options
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set smartindent                 " smart autoindenting when starting a new line
set visualbell                  " visual bell instead of beeping
set wildignore=*.bak,*.o,*.e,*~ " wildmenu: ignore these extensions
set wildmenu                    " command-line completion in an enhanced mode
set title
set hidden
set cindent
set cinoptions=:0
set cul
hi CursorLine cterm=underline
"set colorcolumn=81
"set keywordprg=man\ -a

"set omnifunc=syntaxcomplete#Complete
set path=include/,,/usr/include/
set completeopt=longest,menu
let Tlist_Ctags_Cmd = 'exuberant-ctags'
let g:acp_ignorecaseOption = 0
let g:OmniCpp_GlobalScopeSearch = 1
"let g:OmniCpp_DefaultNamespaces = ["std"]
let g:OmniCpp_NamespaceSearch = 1
let g:OmniCpp_MayCompleteDot = 1
let g:OmniCpp_MayCompleteArrow = 1
let g:OmniCpp_MayCompleteScope = 1
let g:OmniCpp_ShowScopeInAbbr = 1
let g:OmniCpp_ShowPrototypeInAbbr = 1
let g:OmniCpp_DisplayMode = 1
let g:OmniCpp_SelectFirstItem = 2
let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabDefaultCompletionType="context"
let g:SuperTabCrMapping = 1
let g:bufExplorerDetailedHelp=1
let g:bufExplorerShowRelativePath=1

inoremap [] []<left>
inoremap {} {}<left>
inoremap () ()<left>
inoremap <> <><left>
inoremap "" ""<left>
inoremap '' ''<left>
"inoremap , ,<Space>

noremap <F2> :Tlist<CR>
inoremap <F2> <ESC>:Tlist<CR><INSERT>
noremap <F3> :tabnext<CR>
inoremap <F3> <ESC>:tabnext<CR>
noremap <F4> :tabnew 
inoremap <F4> <ESC>:tabnew 
noremap <F5> :SrcExplToggle<CR>
inoremap <F5> <ESC>:SrcExplToggle<CR>
noremap <F7> :BufExplorer<CR>
inoremap <F7> <ESC>:BufExplorer<CR>
noremap <F8> :NERDTreeToggle<CR>
inoremap <F8> <ESC>:NERDTreeToggle<CR>
noremap <leader>v <C-W>v
noremap <leader>s <C-W>s
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l

"let g:C_FormatTime = '%H:%M'
let g:BASH_FormatDate            = '%D'
let g:BASH_FormatTime            = '%H:%M'
let g:BASH_FormatYear            = 'year %Y'
let g:C_Ctrl_j = 'off'
let g:BASH_Ctrl_j = 'off'

let g:SrcExpl_winHeight = 8
let g:SrcExpl_refreshTime = 100
let g:SrcExpl_jumpKey = "<ENTER>"
let g:SrcExpl_gobackKey = "<SPACE>"
let g:SrcExpl_pluginList = [ "__Tag_List__", "NERD_tree_1", "Source_Explorer" ]
let g:SrcExpl_searchLocalDef = 1
let g:SrcExpl_isUpdateTags = 0
let g:SrcExpl_updateTagsCmd = "exuberant-ctags --sort=foldcase -R ."
let g:SrcExpl_updateTagsKey = "<F6>"

let Tlist_Auto_Highlight_Tag = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Highlight_Tag_On_BufEnter = 1
let Tlist_GainFocus_On_ToggleOpen = 1
"let Tlist_Close_On_Select = 1
let tlist_make_settings = 'make;m:makros;t:targets'
let tlist_qmake_settings = 'qmake;t:SystemVariables'

highlight StatusLine term=bold,reverse cterm=bold,reverse ctermfg=green gui=bold,reverse guifg=green
highlight StatusLineNC term=reverse cterm=reverse ctermfg=darkred gui=reverse guifg=darkred

"if filereadable(".vimrc")
"	source .vimrc
"endif
