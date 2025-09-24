" plugin/hexx.vim
"
" HexX - Richard Bentley-Green, 03/09/2025
"
" Hex editing of binary files
"
if exists('g:Hexx_loaded')
  finish
endif
let g:Hexx_loaded = 1

" ----------------------------------
" Wrapper for the hexx#status() function defined in autoload/hexx.vim
" This is defined here to prevent autoload/hexx.vim being brought-in
" prematurely (because it might be called by the status line rendering
" on startup, even if Hexx is not active)
"
" bn - Optional buffer number to read information from. If not specified, the
"      current in-focus buffer is assessed
"
" See hexx#status() in autoload/hexx.vim for details of what is returned
"
function g:HexxStatus(...)
  return (exists('g:Hexx_loaded_autoload') ? ((a:0) ? hexx#status(a:1) : hexx#status()) : {'hexx':0})
endfunction

" ----------------------------------
" Enter HexX edit mode
" (this is not mapped by default - see the description of the ':Hexx' command
"  in the README file for details)
nnoremap <silent> <plug>(HexxStart) :<C-u>call hexx#start()<cr>

" ----------------------------------
" Enter HexX edit mode
command -nargs=0 Hexx call hexx#start()

" Set UTF encoding scheme for 'C' operation - buffer-specific
command -nargs=* HexxUTF call hexx#setUtf(<f-args>)

" ------------------------------------------------------------------------------
" eof
