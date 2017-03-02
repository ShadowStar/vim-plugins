" ============================================================================
" File:        reco.vim
" Description: Reco automates Vim recovery from swap file process
" Maintainer:  ShadowStar, <orphen.leiliu@gmail.com>
" License:     GPLv2+ -- look it up.
"
" ============================================================================

if !exists('g:_reco_dir') || !isdirectory(expand(g:_reco_dir))
let g:_reco_dir="~"
endif

let g:_reco_cleanup = []
augroup Reco
function! DiffSwap()
let _escape_file = substitute(expand("%:p"),"/","\\\\%","g")
let file_path = expand(g:_reco_dir)."/"._escape_file
if filereadable(expand(file_path))
let current_file = expand("%")
exe "tabnew ".file_path
setlocal noswapfile
exe "diffsplit ".current_file
endif
endfunction

function! Reco_CleanUp()
for file in g:_reco_cleanup
exe "silent! !rm ".g:_reco_dir."/".file
endfor
endfunction

function! Reco_SwapCmd()
let _escape_file = substitute(expand("<afile>:p"),"/","\\\\%","g")
exe "silent! ![ \"".g:_reco_dir."/"._escape_file."\" -ot \"<afile>\" ] && cp <afile> ".g:_reco_dir."/"._escape_file
let g:_recover_swap = substitute(v:swapname,"/","\\\\%","g")
exe "silent! ![ \"".g:_reco_dir."/".g:_recover_swap."\" -ot \"".v:swapname."\" ] && cp ".v:swapname." ".g:_reco_dir."/".g:_recover_swap
let v:swapchoice = 'd'
call extend(g:_reco_cleanup,[g:_recover_swap,_escape_file])
au Reco VimLeavePre * :call Reco_CleanUp()
au Reco BufEnter * :call Reco_RecoverSwap()
endfunction

function! Reco_RecoverSwap()
if exists("g:_recover_swap")
set noswapfile
exe "silent! recover! ".g:_reco_dir."/".g:_recover_swap
set swapfile
unlet g:_recover_swap
let _escape_file = substitute(expand("%:p"),"/","\\\\%","g")
let file_path = expand(g:_reco_dir)."/"._escape_file
if filereadable(expand(file_path))
echo "Backup file exists if you like :call DiffSwap() to compare in new tab"
endif
echo "Recovery successful"
endif
au! Reco BufEnter
endfunction

au Reco SwapExists * v:swapcommand = :call Reco_SwapCmd()
