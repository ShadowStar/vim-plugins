" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=darkred guibg=#382424
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter,FileType !diff match ExtraWhitespace /\(\s\+$\|\ \t\)/
autocmd BufWinEnter,FileType diff match ExtraWhitespace /^$/
" the above flashes annoyingly while typing, be calmer in insert mode
autocmd InsertLeave,FileType !diff match ExtraWhitespace /\(\s\+$\|\ \t\)/
autocmd InsertLeave,FileType diff match ExtraWhitespace /^$/
autocmd InsertEnter,FileType !diff match ExtraWhitespace /\s\+\%#\@<!$/

function! s:FixWhitespace(line1,line2)
    if &filetype != "diff"
        let l:save_cursor = getpos(".")
        silent! execute ':' . a:line1 . ',' . a:line2 . 's/\s\+$//'
        silent! execute ':' . a:line1 . ',' . a:line2 . 's/\ \t/\t/'
        call setpos('.', l:save_cursor)
    endif
endfunction

" Run :FixWhitespace to remove end of line white space.
command! -range=% FixWhitespace call <SID>FixWhitespace(<line1>,<line2>)

