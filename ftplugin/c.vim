" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C
"     Plugin :  c.vim 
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_C_ftplugin")
  finish
endif
let b:did_C_ftplugin = 1

let g:SuperTabNoCompleteAfter = ['^', '\s', ',', ';', ':', '(', ')', '[', ']', '{', '}']

setlocal tabstop=8
setlocal shiftwidth=8
setlocal softtabstop=8
setlocal textwidth=80
setlocal noexpandtab
setlocal cindent
setlocal smartindent
setlocal formatoptions=tcqlron
setlocal cinoptions=:0,l1,t0,g0,(0
setlocal keywordprg=man\ -S\ 2:3

if exists('g:viewdoc_man_cmd')
	let g:viewdoc_man_cmd=&keywordprg
endif

function! <sid>Str2Hex(type)
  let l:type = a:type
  let l:hex = matchstr(getline('.'), '\(0x\|\\x\)')
  if l:hex == ""
    if l:type == '0x'
      silent execute "s/\\x\\x/\\='0x'.toupper(submatch(0)).', '/g"
    else
      silent execute "s/\\x\\x/\\='\\x'.toupper(submatch(0))/g"
    endif
  else
    if matchstr(getline('.'), '0x\x\x,') != ""
      silent execute "s/0x\\(\\x\\x\\)[,]\\s*/\\1/g"
    elseif matchstr(getline('.'), '\\[xX]\x\x') != ""
      silent execute "s/\\\\[xX]\\(\\x\\x\\)/\\1/g"
    endif
  endif
endfunction

map <leader>x :call <sid>Str2Hex('x')<CR>
map <leader>0x :call <sid>Str2Hex('0x')<CR>

"
"-------------------------------------------------------------------------------
" additional mapping : complete a classical C comment: '/*' => '/* | */'
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
"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:C_MapLeader"
"-------------------------------------------------------------------------------
call C_SetMapLeader ()
"
"-------------------------------------------------------------------------------
" additional mapping : Make tool
"-------------------------------------------------------------------------------
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>
"
"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call C_ResetMapLeader ()
"
