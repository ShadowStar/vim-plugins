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
set complete+=k
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
set statusline=%{toupper(mode(1))}\|\ %y%f%m%=[%{&ff},%{&fenc}]\ 0x%B\ %v/%{strdisplaywidth(getline(\".\"))}C,%l/%LL\ --%p%%--
set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo
set t_ZH=[3m
set t_ZR=[23m
set title
set viminfo='20,\"500,n/~/.cache/viminfo      " Keep a .viminfo file.
set visualbell                  " visual bell instead of beeping
set wildignore=*.bak,*.o,*.ko,*.e,*~ " wildmenu: ignore these extensions
set wildignore+=*.tar,*.tgz,*.gz,*.bz2,*.lzma,*.zip,*.rar
set wildignore+=*.pdf,*.ppt,*.pptx,*.doc,*.docx,*.xls,*.xlsx
set wildignore+=*.rmvb,*.avi,*.mpg,*.mpeg,*.mp4,*.mkv,*.swf
set wildignore+=*.mp3,*.aac,*.wav,*.flac
set wildignore+=*.obj,*.elf,*.lib,*.so,*.a,*.la,*.lo,*.dll,*.dylib
set wildignore+=*.out,*.exe
set wildmenu                    " command-line completion in an enhanced mode
set notagbsearch
set nofileignorecase
set shortmess-=S
set mouse-=a

" Don't use Ex mode, use Q for formatting
map Q gq
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l
noremap <silent> <leader><leader> :silent wa<CR>
inoremap <silent> <leader><leader> <ESC>:silent wa<CR>

tnoremap <C-h> <C-W>h
tnoremap <C-j> <C-W>j
tnoremap <C-k> <C-W>k
tnoremap <C-l> <C-W>l

function! Term_insert()
  if &buftype == 'terminal'
    execute 'silent! normal i'
  endif
endfunction

autocmd BufEnter * :call Term_insert()

let s:term_buf_nr = -1
let s:term_win_nr = -1

function! ToggleTerminal(m, k)
  if has('textprop') && has('patch-8.2.0286') && a:m == 'p'
    let l:m = 'p'
  else
    let l:m = 'b'
  endif

  if has('terminal')
    if l:m == 'p'
      let b:win_h = &lines / 3 * 2
      let b:win_w = &columns / 3 * 2
      let s:term_ops = {
            \ 'maxwidth': b:win_w,
            \ 'minwidth': b:win_w,
            \ 'maxheight': b:win_h,
            \ 'minheight': b:win_h,
            \ 'title': &shell,
            \ 'border': [1, 1, 1, 1],
            \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            \ 'borderhighlight': ['Normal']
            \ }
    else
      let b:win_h = &lines / 3
    endif

    if s:term_buf_nr != -1 && term_getstatus(s:term_buf_nr) == 'finished'
      execute "bdelete " . s:term_buf_nr
      let s:term_buf_nr = -1
      let s:term_win_nr = -1
    endif

    if s:term_buf_nr == -1 || bufloaded(s:term_buf_nr) != 1
      if l:m == 'p'
        let s:term_buf_nr = term_start(&shell, #{hidden: 1, term_finish: 'close'})
        let s:term_win_nr = popup_create(s:term_buf_nr, s:term_ops)
      else
        execute "bot term ++rows=" . b:win_h
        let s:term_buf_nr = bufnr("$")
      endif
    else
      if l:m == 'p'
        if s:term_win_nr == -1
          let s:term_win_nr = popup_create(s:term_buf_nr, s:term_ops)
        else
          call popup_close(s:term_win_nr)
          let s:term_win_nr = -1
        endif
      else
        let s:term_win_nr = bufwinnr(s:term_buf_nr)
        if s:term_win_nr == -1
          execute "bot sbuffer " . s:term_buf_nr . '| resize ' . b:win_h
        else
          execut s:term_win_nr . 'wincmd w'
        endif
      endif
    endif

    if l:m != 'p'
      execute 'tnoremap ' . a:k . ' <C-\><C-N>:q<CR>'
      execute 'tnoremap <Esc> <C-\><C-N>'
      execute 'tnoremap <Esc><Esc> <C-\><C-N>'
    endif
  else
    echom "Do NOT support feature 'terminal'"
  endif
endfunction

set timeout timeoutlen=500
set ttimeout ttimeoutlen=100

nnoremap <leader>c :call ToggleTerminal('p', '<leader>c')<CR>
tnoremap <leader>c <C-\><C-N>:call ToggleTerminal('p', '<leader>c')<CR>
nnoremap <C-s> :call ToggleTerminal('b', '<C-s>')<CR>

nnoremap <C-c> :shell<CR>
inoremap <C-c> <ESC>:shell<CR>

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
set omnifunc=syntaxcomplete#Complete

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/.plugged')

Plug 'inkarkat/vim-ingo-library', { 'branch': 'stable' }
Plug 'inkarkat/vim-CountJump', { 'branch': 'stable' }
Plug 'inkarkat/vim-ConflictMotions', { 'branch': 'stable' }
Plug 'inkarkat/vim-ConflictDetection', { 'branch': 'stable' }
Plug 'inkarkat/vim-SyntaxRange', { 'branch': 'stable' }
Plug 'inkarkat/vim-LogViewer', { 'branch': 'stable' }
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'ctrlpvim/ctrlp.vim', { 'tag': '*' }
Plug 'mbbill/undotree'
Plug 'christianrondeau/vim-base64'
Plug 'chrisbra/csv.vim'
Plug 'junkblocker/patchreview-vim'
Plug 'scrooloose/nerdtree', { 'tag': '*' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mhinz/vim-startify'
Plug 'rickhowe/diffchar.vim'
Plug 'junegunn/vim-easy-align', { 'tag': '*' }
Plug 'machakann/vim-highlightedyank'
Plug 'johngrib/vim-git-msg-wheel'
Plug 'powerman/vim-plugin-viewdoc'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs', { 'tag': '*' }
Plug 'duggiefresh/vim-easydir'
Plug 'lfv89/vim-interestingwords'
Plug 'ShadowStar/code_complete'
Plug 'mbbill/echofunc'
Plug 'embear/vim-localvimrc'
Plug 'rickhowe/spotdiff.vim'
Plug 'rhysd/git-messenger.vim'
Plug 'markonm/traces.vim'
Plug 'shirk/vim-gas'
Plug 'skywind3000/vim-dict'
Plug 'ludovicchabant/vim-gutentags'
Plug 'andymass/vim-matchup'
Plug 'PAntoine/vimgitlog'
Plug 'habamax/vim-shout'
Plug 'girishji/vimsuggest'

call plug#end()

if !exists('##TextYankPost')
  map y <Plug>(highlightedyank)
endif

noremap <F2> :TagbarToggle<CR>
inoremap <F2> <ESC>:TagbarToggle<CR><INSERT>
noremap <F6> :call GITLOG_ToggleWindows()<CR>
inoremap <F6> <ESC>:call GITLOG_ToggleWindows()<CR>
noremap <F7> :BufExplorerHorizontalSplit<CR>
inoremap <F7> <ESC>:BufExplorerHorizontalSplit<CR>
noremap <F8> :NERDTreeToggle<CR>
inoremap <F8> <ESC>:NERDTreeToggle<CR>
noremap <leader>f :KeyFollow<CR>
noremap <leader>d :VCSDiff<CR>
noremap <leader>l :VCSLog<CR>
noremap <leader>b :VCSBlame<CR>
noremap <leader>u :UndotreeToggle<CR>

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline
autocmd FileType * execute 'setlocal dictionary='.expand($HOME.'/.vim/dict/'.&filetype.'.dict')

let VCSCommandSplit='vertical'
let g:gutentags_modules = [ 'ctags', 'cscope' ]

let g:gutentags_file_list_command = {
      \ 'markers': {
      \ '.git': 'find $(git ls-files|grep -E "\.(c|h|S|cpp|hpp)$"|xargs -n 1 dirname|cut -d"/" -f 1|sort -u) \( -name "*.[chS]" -o -name "*.[ch]pp" \) -type f',
      \ },
      \ 'default': 'find . \( -name "*.[chS]" -o -name "*.[ch]pp" \) -type f'
      \ }
" gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let g:gutentags_cache_dir = expand('~/.cache/tags')

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

set rtp+=/opt/homebrew/opt/fzf
let g:snipMate = { 'snippet_version' : 1 }
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

let g:VCSCommandDeleteOnHide = 1
let g:C_Dictionary_File = $HOME.'/.vim/c-support/wordlists/std-keywords.list'
let g:C_Ctrl_j = 'off'
let g:BASH_Ctrl_j = 'off'
let g:Awk_Ctrl_j = 'off'
let g:Vim_Ctrl_j = 'off'

let NERDTreeWinPos = "right"
let g:tagbar_left = 1
let g:tagbar_autoclose = 1

let g:AutoPairsMapCR = 0

let g:update_last_time_format = '%x %X'
let g:update_last_end_line = 30

let g:viewdoc_openempty = 0
"if filereadable(".vimrc")
"  source .vimrc
"endif

