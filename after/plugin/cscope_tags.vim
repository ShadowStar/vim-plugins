" ==============================================================================
" Vim Plugin file
" Auto load cscope & ctags DB
" ShadowStar <orphen.leiliu@gmail.com>
" ==============================================================================

if exists("g:loaded_cscope_tags")
  finish
endif

let g:loaded_cscope_tags = 1

if (!exists("cscope_tags_db_list"))
  let g:cscope_tags_db_list = []
endif

if (!exists("cscope_tags_dir_list"))
  let g:cscope_tags_dir_list = []
endif

function! s:Find(name, dir)
  let files = system("find " . a:dir . " '\(' -name SCCS -o -name BitKeeper -o -name .svn -o -name CVS -o -name .pc -o -name .hg -o -name .git '\)' -prune -o -name '" . a:name . "' -print")
  return split(files)
endfunction

function! s:LoadCscope(...)
  if a:0 < 1
      let l:dir = expand('%:p:h')
    if empty(l:dir)
      let l:dir = getcwd()
    endif
  else
    let l:dir = expand(a:1)
  endif
  if (index(g:cscope_tags_dir_list, l:dir) >= 0)
    return
  endif
  if (!filereadable(l:dir . '/cscope.out') && !filereadable(l:dir . '/tags'))
    return
  endif
  call add(g:cscope_tags_dir_list, l:dir)
  let db = s:Find('cscope.out',l:dir)
"  let db = findfile("cscope.out", "**", -1)
  if (!empty(db))
    set nocscopeverbose " suppress 'duplicate connection' error
    for item in db
      if (index(g:cscope_tags_db_list, item) < 0)
        call add(g:cscope_tags_db_list, item)
        let path = strpart(item, 0, match(item, "/cscope.out$"))
        exe "cs add " . item . " " . path
      endif
    endfor
    set cscopeverbose
  endif
"  let tagfile = findfile("tags", "**", -1)
  let tagfile = s:Find('tags', l:dir)
  if (!empty(tagfile))
    for item in tagfile
      if (index(g:cscope_tags_db_list, item) >= 0)
        call remove(tagfile, index(tagfile, item))
      endif
    endfor
    let g:cscope_tags_db_list += tagfile
    let taglist = join(tagfile, ",")
    exec "set tags+=" . taglist
  endif
endfunction

autocmd BufEnter /*.[chS] call s:LoadCscope(expand('%:p:h'))
autocmd VimEnter /*.[chS] call s:LoadCscope(getcwd())

command! -nargs=* -complete=dir LoadCscope call s:LoadCscope(<f-args>)

