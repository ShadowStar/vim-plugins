scriptencoding utf-8
" ^^ Please leave the above line at the start of the file.

filetype plugin on
filetype indent on
syntax on

set autoindent                  " Always set auto-indenting on
set autoread                    " read open files again when changed outside Vim
set autowrite                   " write a modified buffer on each :next , ...
set backspace=indent,eol,start  " backspacing over everything in insert mode
set cindent
set cinoptions=:0,l1,t0,g0,(0
set completeopt=longest,menu
set cursorline
set formatoptions=tcqlron
set hidden
set history=50                  " keep 50 lines of command line history
set hlsearch                    " highlight the last used search pattern
set imdisable
set iminsert=0
set incsearch                   " do incremental searching
set laststatus=2
set listchars=tab:>.,eol:\$     " strings to use in 'list' mode
set nocompatible                " Use Vim defaults (much better!)
set nomodeline
set path=include/,,/usr/include/
set popt=left:8pc,right:3pc     " print options
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set smartindent                 " smart autoindenting when starting a new line
set statusline=%y%f%m%=[%{&ff},%{&fenc}]\ 0x%B\ %v/%{strdisplaywidth(getline(\".\"))}C,%l/%LL\ --%p%%--
set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo
set t_ZH=[3m
set t_ZR=[23m
set title
set viminfo='20,\"500           " Keep a .viminfo file.
set visualbell                  " visual bell instead of beeping
set wildignore=*.bak,*.o,*.ko,*.e,*~ " wildmenu: ignore these extensions
set wildignore+=*.tar,*.tgz,*.gz,*.bz2,*.lzma,*.zip,*.rar
set wildignore+=*.pdf,*.ppt,*.pptx,*.doc,*.docx,*.xls,*.xlsx
set wildignore+=*.rmvb,*.avi,*.mpg,*.mpeg,*.mp4,*.mkv,*.swf
set wildignore+=*.mp3,*.aac,*.wav,*.flac
set wildmenu                    " command-line completion in an enhanced mode

" Don't use Ex mode, use Q for formatting
map Q gq
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l
noremap <C-c> :shell<CR>
noremap <leader>v <C-W>v
noremap <leader>s <C-W>s
noremap <F3> :tabnext<CR>
inoremap <F3> <ESC>:tabnext<CR>
noremap <F4> :tabnew 
inoremap <F4> <ESC>:tabnew 

"inoremap [] []<left>
"inoremap {} {}<left>
"inoremap () ()<left>
"inoremap <> <><left>
"inoremap "" ""<left>
"inoremap '' ''<left>
"inoremap , ,<Space>

if v:version >= 703
  set colorcolumn=+1
endif

if v:version >= 700
  set numberwidth=3
endif

if v:lang =~? "UTF-8$"
  set fileencodings=utf-8
endif
if v:lang =~? "^ko"
  set fileencodings+=euc-kr
  set guifontset=-*-*-medium-r-normal--16-*-*-*-*-*-*-*
elseif v:lang =~? "^ja_JP"
  set fileencodings+=euc-jp
  set guifontset=-misc-fixed-medium-r-normal--14-*-*-*-*-*-*-*
elseif v:lang =~? "^zh_TW"
  set fileencodings+=big5
  set guifontset=-sony-fixed-medium-r-normal--16-150-75-75-c-80-iso8859-1,-taipei-fixed-medium-r-normal--16-150-75-75-c-160-big5-0
elseif v:lang =~? "^zh_CN"
  set fileencodings+=gb2312
  set fileencodings+=gbk
  set fileencodings+=gb18030
  set guifontset=*-r-*
endif

if &fileencodings !~? "ucs-bom"
  set fileencodings^=ucs-bom
endif

if &fileencodings !~? "utf-8"
  set fileencodings+=utf-8
endif

set fileencodings+=default

if &term ==? "xterm"
  set t_Sb=^[4%dm
  set t_Sf=^[3%dm
  set ttymouse=xterm2
endif

if "" == &shell
  if executable("/bin/bash")
    set shell=/bin/bash
  elseif executable("/bin/sh")
    set shell=/bin/sh
  endif
endif

if has("eval")
  let is_bash=1
endif

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

function! Get_Locale()
  if match($LANG, "UTF-8$") > 0
    return 'en_US.UTF-8'
  else
    if !empty($LANG)
      return $LANG
    else
      return 'POSIX'
  endif
endfunction

" Find file in current directory and edit it.
function! FindEdit(...)
  if a:0 > 1
    let path = a:1
    let query = a:2
  else
    let path = "./"
    if a:0 == 0
      let query = expand("<cfile>")
    else
      let query = a:1
    endif
  endif

  if !exists("g:FindIgnore")
    let g:FindIgnore = ['.swp', '.pyc', '.class', '.git', '.svn', 'SCCS', 'BitKeeper', 'CVS', '.pc', '.hg']
  endif
  let ignore = " | egrep -v '" . join(g:FindIgnore, "|") . "'"

  let l:list = system("find " . path . " -type f -iname '*" . query . "*'" . ignore)
  let l:num = strlen(substitute(l:list, "[^\n]", "", "g"))

  if l:num < 1
    echo "'" . query . "' not found"
    return
  endif

  if l:num == 1
    exe "open " . substitute(l:list, "\n", "", "g")
  else
    let tmpfile = tempname()
    exe "redir! > " . tmpfile
    silent echon l:list
    redir END
    let old_efm = &efm
    set efm=%f

    if exists(":cgetfile")
      execute "silent! cgetfile " . tmpfile
    else
      execute "silent! cfile " . tmpfile
    endif

    let &efm = old_efm

    " Open the quickfix window below the current window
    botright copen

    call delete(tmpfile)
  endif
endfunction

command! -nargs=* -complete=file FindEdit call FindEdit(<f-args>)

function! KeyFollow()
  if !exists("g:KeyFollowMatch")
    let g:KeyFollowMatch = 0
  endif
  hi KeyFollow term=reverse cterm=bold ctermfg=5 ctermbg=7
  call matchdelete(g:KeyFollowMatch)
  let g:KeyFollowMatch = matchadd("KeyFollow", '\<' . expand("<cword>") . '\>')
endfunction

function! KeyFollowToggle()
  if !exists("g:KeyFollow")
    let g:KeyFollow = 0
  endif
  if (g:KeyFollow == 0)
    augroup KeyFollow
    au!
    autocmd CursorMoved * silent! call KeyFollow()
    augroup END
    let g:KeyFollow = 1
  else
    let g:KeyFollow = 0
    autocmd! KeyFollow
    call matchdelete(g:KeyFollowMatch)
  endif
endfunction

command! -nargs=0 KeyFollow call KeyFollowToggle()

hi CursorLine cterm=underline

runtime macros/matchit.vim

colorscheme shadowstar

hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=green gui=bold,reverse guifg=green
hi StatusLineNC term=reverse cterm=reverse ctermfg=darkred gui=reverse guifg=darkred

let c_space_errors = 1
let c_gnu = 1
let g:c_syntax_for_h = 1
"set omnifunc=syntaxcomplete#Complete

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/.plugged')

Plug 'inkarkat/vim-ingo-library', { 'branch': 'stable' }
Plug 'wesleyche/SrcExpl'
Plug 'scrooloose/nerdtree', { 'tag': '*' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'wesleyche/Trinity', { 'do': 'rm -f plugin/NERD_tree.vim' }
Plug 'mhinz/vim-startify'
Plug 'rickhowe/diffchar.vim'
Plug 'junegunn/vim-easy-align', { 'tag': '*' }
Plug 'machakann/vim-highlightedyank'
Plug 'johngrib/vim-git-msg-wheel'
Plug 'powerman/vim-plugin-viewdoc'

call plug#end()

if !exists('##TextYankPost')
  map y <Plug>(highlightedyank)
endif

noremap <F2> :TagbarToggle<CR>
inoremap <F2> <ESC>:TagbarToggle<CR><INSERT>
noremap <F5> :TrinityToggleAll<CR>
inoremap <F5> <ESC>:TrinityToggleAll<CR>
noremap <F6> :call GITLOG_ToggleWindows()<CR>
inoremap <F6> <ESC>:call GITLOG_ToggleWindows()<CR>
noremap <F7> :BufExplorerHorizontalSplit<CR>
inoremap <F7> <ESC>:BufExplorerHorizontalSplit<CR>
noremap <F8> :NERDTreeToggle<CR>
inoremap <F8> <ESC>:NERDTreeToggle<CR>
noremap <leader>f :KeyFollow<CR>
noremap <leader>d :VCSDiff<CR>
noremap <leader>l :VCSLog<CR>
noremap <leader>u :GundoToggle<CR>

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

"let g:bufExplorerDetailedHelp=1
let g:bufExplorerShowRelativePath=1
let g:bufExplorerSplitVertSize=30
let g:bufExplorerSplitHorzSize=10

let g:EchoFuncKeyPrev = '<C-k>'
let g:EchoFuncKeyNext = '<C-j>'
let g:VCSCommandDeleteOnHide = 1
let g:C_Dictionary_File = $HOME.'/.vim/c-support/wordlists/std-keywords.list'
let g:C_Ctrl_j = 'off'
let g:BASH_Ctrl_j = 'off'
let g:Awk_Ctrl_j = 'off'
let g:Vim_Ctrl_j = 'off'

let g:SrcExpl_winHeight = 8
let g:SrcExpl_refreshTime = 100
let g:SrcExpl_jumpKey = "<ENTER>"
let g:SrcExpl_gobackKey = "<SPACE>"
let g:SrcExpl_pluginList = [ "__Tag_List__", "NERD_tree_1", "Source_Explorer" ]
let g:SrcExpl_searchLocalDef = 1
let g:SrcExpl_isUpdateTags = 0
let g:SrcExpl_updateTagsCmd = "exuberant-ctags --sort=foldcase -R ."

let Tlist_Ctags_Cmd = 'exuberant-ctags'
let Tlist_Auto_Highlight_Tag = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Highlight_Tag_On_BufEnter = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Inc_Winwidth = 0
"let Tlist_Close_On_Select = 1
let tlist_make_settings = 'make;m:makros;t:targets'
let tlist_qmake_settings = 'qmake;t:SystemVariables'

let g:tagbar_left = 1
let g:tagbar_autoclose = 1

let g:loaded_syntastic_plugin = 1
let g:AutoPairsMapCR = 0

let g:update_last_time_format = '%x %X'
let g:update_last_end_line = 30

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

runtime simple_highlighting.vimrc

"if filereadable(".vimrc")
"  source .vimrc
"endif

