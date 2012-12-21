" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=darkred guibg=#382424
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter,FileType [^(diff|git)] match ExtraWhitespace /^\(\s*\n\)\{2,}\| \+\ze\t\|\s\+$/
autocmd BufWinEnter,FileType diff,git match ExtraWhitespace /^\([+ ]\s*\n\)\{2,}\|\%>1v \+\ze\t\|\%>1v\s\+$/
"autocmd BufWinEnter,FileType diff match ExtraWhitespace /^[^ \ndi+\-@]/
" the above flashes annoyingly while typing, be calmer in insert mode
autocmd InsertLeave,FileType [^(diff|git)] match ExtraWhitespace /^\(\s*\n\)\{2,}\| \+\ze\t\|\s\+$/
autocmd InsertLeave,FileType diff,git match ExtraWhitespace /^\([+ ]\s*\n\)\{2,}\|\%>1v \+\ze\t\|\%>1v\s\+$/
"autocmd InsertLeave,FileType diff match ExtraWhitespace /^[^ \ndi+\-@]/
"autocmd InsertEnter,FileType [^(diff)] match ExtraWhitespace /\s\+\%#\@<!$/
"autocmd Syntax [^(diff|git)] syn match ExtraWhitespace / \+\ze\t\|\s\+$/
"autocmd Syntax diff,git syn match ExtraWhitespace /\%>1v\ \+\ze\t\|\%>1v\s\+$/

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

