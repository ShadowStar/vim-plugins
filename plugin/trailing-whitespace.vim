" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces

if exists("g:loaded_trailing_whitespace")
  finish
endif

let g:loaded_trailing_whitespace = 1

function! s:TrailingWhitespace()
  hi TWError term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
  if &filetype == "diff" || &filetype == "git" || &filetype == "gitcommit"
    match TWError	/^\([+ ]\s*\n\)\{2,}\|\%>1v \+\ze\t\|\%>1v\s\+$/
  else
    match TWError	/^\(\s*\n\)\{2,}\| \+\ze\t\|\s\+$/
  endif
endfunction

autocmd BufWinEnter,InsertLeave * call s:TrailingWhitespace()

if version >= 702
  autocmd BufWinLeave * call clearmatches()
endif

function! s:FixWhitespace(line1,line2)
    if &filetype != "diff"
        let l:save_cursor = getpos(".")
        silent! execute ':' . a:line1 . ',' . a:line2 . 's/\s\+$//'
        silent! execute ':' . a:line1 . ',' . a:line2 . 's/\ \t/\t/'
        silent! execute ':' . a:line1 . ',' . a:line2 . 's/^\_s\+$//'
        call setpos('.', l:save_cursor)
    endif
endfunction

" Run :FixWhitespace to remove end of line white space.
command! -range=% FixWhitespace call <SID>FixWhitespace(<line1>,<line2>)

if exists('g:strip_trailing_lines_auto')
	autocmd BufWritePre * FixWhitespace
endif
