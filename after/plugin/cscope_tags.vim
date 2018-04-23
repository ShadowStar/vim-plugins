" ==============================================================================
" Vim Plugin file
" Auto load cscope & ctags DB
" ShadowStar <orphen.leiliu@gmail.com>
" ==============================================================================

if exists("g:loaded_cscope_tags")
  finish
endif

let g:loaded_cscope_tags = 1

function! s:LoadCscope(...)
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

function! s:ClearCscope()
  set nocscopeverbose
  exec "cs kill -1"
  exec "set tags="
  set cscopeverbose
endfunction

autocmd BufEnter /*.[chS] call s:LoadCscope(expand('%:p:h'))

command! -nargs=* -complete=dir LoadCscope call s:LoadCscope(<f-args>)
command! ClearCscope call s:ClearCscope()

