" ==============================================================================
" Vim Plugin file
" Auto load cscope & ctags DB
" ShadowStar <orphen.leiliu@gmail.com>
" ==============================================================================

if exists("g:loaded_cscope_tags")
  finish
endif

let g:loaded_cscope_tags = 1

function! s:CScopeLoad(...)
  if a:0 < 1
    let l:dir = expand('%:p:h')
    if empty(l:dir)
      let l:dir = getcwd()
    endif
  else
    let l:dir = expand(a:1)
  endif

  let dbfile = findfile("cscope.out", l:dir . ";", -1)
  let dbfile += findfile("cscope.out", l:dir . "**", -1)
  let db = filter(dbfile, 'index(dbfile, v:val, v:key+1)==-1')

  let tagfile = split(&tags, ",")
  let tagfile += findfile("tags", l:dir . ";", -1)
  let tagfile += findfile("tags", l:dir . "**", -1)
  let tag = filter(tagfile, 'index(tagfile, v:val, v:key+1)==-1')

  if (empty(db) && empty(tag))
    return
  endif

  if (!empty(db))
    set nocscopeverbose " suppress 'duplicate connection' error
    for item in db
      let path = matchstr(item, ".*/")
      exe "cs add " . item . " " . path
    endfor
    set cscopeverbose
  endif

  if (!empty(tag))
    let taglist = join(tag, ",")
    exec "set tags=" . taglist
  endif
endfunction

function! s:CScopeReload()
  set nocscopeverbose
  let l:tags = &tags
  exec "set tags="
  exec "cs reset"
  exec "set tags=" . l:tags
endfunction

function! s:CScopeClear()
  set nocscopeverbose
  exec "cs kill -1"
  exec "set tags="
  set cscopeverbose
endfunction

autocmd BufEnter /*.[chS] call s:CScopeLoad(expand('%:p:h'))

command! -nargs=* -complete=dir CScopeLoad call s:CScopeLoad(<f-args>)
command! CScopeReload call s:CScopeReload()
command! CScopeClear call s:CScopeClear()

