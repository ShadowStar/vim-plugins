" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C / C++
"     Plugin :  c.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
"
if exists("b:did_C_ftplugin")
  finish
endif
let b:did_C_ftplugin = 1

set colorcolumn=81
set keywordprg=man\ -S\ 2:3
"set tags=tags;/

function! s:Find(name)
  let files = system("find " . getcwd() . " '\(' -name SCCS -o -name BitKeeper -o -name .svn -o -name CVS -o -name .pc -o -name .hg -o -name .git '\)' -prune -o -name '" . a:name . "' -print")
  return split(files)
endfunction

function! LoadCscope()
  let db = s:Find('cscope.out')
"  let db = findfile("cscope.out", "**", -1)
  if (!empty(db))
    set nocscopeverbose " suppress 'duplicate connection' error
    for item in db
      let path = strpart(item, 0, match(item, "/cscope.out$"))
      exe "cs add " . item . " " . path
    endfor
    set cscopeverbose
  endif
"  let tagfile = findfile("tags", "**", -1)
  let tagfile = s:Find('tags')
  if (!empty(tagfile))
    let taglist = join(tagfile, ",")
    exec "set tags=" . taglist
  endif
endfunction

autocmd VimEnter /* call LoadCscope()
"
"-------------------------------------------------------------------------------
" ADDITIONAL MAPPING : complete a classical C comment: '/*' => '/* | */'
"-------------------------------------------------------------------------------
inoremap  <buffer>  /*       /*<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /*      s/*<Space><Space>*/<Left><Left><Left><Esc>p
"
"-------------------------------------------------------------------------------
" additional mapping : complete a classical C multi-line comment:
"                      '/*<CR>' =>  /*
"                                    * |
"                                    */
"-------------------------------------------------------------------------------
inoremap  <buffer>  /*<CR>  /*<CR><CR>/<Esc>kA<Space>
"
"-------------------------------------------------------------------------------
" additional mapping : {<CR> always opens a block
"-------------------------------------------------------------------------------
inoremap  <buffer>  {<CR>    {<CR>}<Esc>O
vnoremap  <buffer>  {<CR>   S{<CR>}<Esc>Pk=iB
"
