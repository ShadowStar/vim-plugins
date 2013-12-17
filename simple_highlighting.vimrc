
" Basic Functions {{{
function NewArray(length, elemVal)
    let retVal = []
    for idx in range(a:length)
        let retVal += [deepcopy(a:elemVal)]
    endfor
    return retVal
endfunction

function Zeros(length)
    return NewArray(a:length, 0)
endfunction

function FlatternStrArr(strArr, seperator) "Flattern String Array into signal string
    if len(a:strArr) == 0
        return ''
    endif
    let ret = a:strArr[0]
    for str in a:strArr[1:]
        let ret .= a:seperator.str
    endfor
    return ret
endfunction

"function below taken form <http://vim.wikia.com/wiki/Windo_and_restore_current_window>
" Just like windo, but restore the current window when done.
function! WinDo(command)
  let currwin=winnr()
  execute 'windo ' . a:command
  execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" }}}

"Highlight words extension {{{
"
" useful web link: http://www.ibm.com/developerworks/linux/library/l-vim-script-1/index.html
" http://vim.wikia.com/wiki/Highlight_multiple_words
highlight hlg0 ctermbg=DarkGreen   guibg=DarkGreen      ctermfg=white guifg=white
highlight hlg1 ctermbg=DarkCyan    guibg=DarkCyan       ctermfg=white guifg=white
highlight hlg2 ctermbg=Blue        guibg=Blue           ctermfg=white guifg=white
highlight hlg3 ctermbg=DarkMagenta guibg=DarkMagenta    ctermfg=white guifg=white
highlight hlg4 ctermbg=DarkRed     guibg=DarkRed        ctermfg=white guifg=white
highlight hlg5 ctermbg=DarkYellow  guibg=DarkYellow     ctermfg=white guifg=white
highlight hlg6 ctermbg=Brown       guibg=Brown          ctermfg=white guifg=white
highlight hlg7 ctermbg=DarkGrey    guibg=DarkGrey       ctermfg=white guifg=white
let s:TOTAL_HL_NUMBERS = 8

let g:hlPat   = NewArray(s:TOTAL_HL_NUMBERS,[])  "stores the patters
let s:REGEX_OR = '\|'

"press [<number>] <Leader> h -> to highligt the whole word under the cursor
"   highligted colour is determed by the number the number defined above
nmap <Leader>h :<C-U> exe "call HighlightAdd(".v:count.",'\\<".expand('<cword>')."\\>')" <CR> 
"NOTE: above funtion can match on an empty pattern '\<\>' however this doesn't
"   seem to have any magor negetive effects so is not fixed

"Hc [0,2...] -> clears the highlighted patters listed or all if no arguments
"   are passed
command -nargs=* Hc call HighlightClear(<args>)

command -nargs=* Hs call HighlightSearch(<args>) | set hlsearch

function HighlightAdd(hlNum, pattern)
    if (s:HighlightCheckNum(a:hlNum) != 0) &&( a:pattern != '') && (a:pattern != '\<\>')
        let g:hlPat[a:hlNum] += [a:pattern]
        call WinDo('call s:HighlightUpdatePriv('.a:hlNum.')')
    endif
endfunction

let s:HIGHLIGHT_PRIORITY = -1  " -1 => do not overide default serach highlighting
function s:HighlightUpdatePriv(hlNum) "if patern is black will set w:hlIdArr[a:hlNum] to  -1
    if w:hlIdArr[a:hlNum] > 0
        call matchdelete(w:hlIdArr[a:hlNum])
    end
    let w:hlIdArr[a:hlNum] = matchadd('hlg'.a:hlNum, HighlightPattern(a:hlNum), s:HIGHLIGHT_PRIORITY)
endfunction

if !exists("s:au_highlight_loaded") "guard
    let s:au_highlight_loaded = 1 "only run commands below once
    autocmd WinEnter    * call HighlightWinEnter()
    autocmd BufEnter    * call HighlightWinEnter()
endif

"TODO: Fix help window issue: when help window is open matches already apply
"but as these are on another buffer the mach numbers will not be deleted
function HighlightWinEnter()
    if !exists("w:displayed")
        let w:displayed  = 1
        let w:hlIdArr = Zeros(s:TOTAL_HL_NUMBERS)
        for idx in range(s:TOTAL_HL_NUMBERS)
            if len(g:hlPat[idx]) > 0
                call s:HighlightUpdatePriv(idx)
            endif
        endfor
    endif
endfunction

function HighlightClear(...)
    "uses mark x to stop matchdelete from shifting the cursor
    "TODO: fix so mark x is no longer required
    "normal mx
    if a:0 == 0
        for idx in range(s:TOTAL_HL_NUMBERS) "range stopes BEFORE
            call s:HighlightClearPriv(eval(idx))
        endfor
    else
        for idx in range(1, a:0) "range stopes AFTER
            call s:HighlightClearPriv(eval('a:'.idx))
        endfor
    endif
    "normal `x
"    echo eval('g:matchG'.a:arg)
endfunction

function s:HighlightClearPriv(hlNum)
    if s:HighlightCheckNum(a:hlNum) && w:hlIdArr[a:hlNum] > 0
        call WinDo('call s:HighlightClearBuffPriv('.a:hlNum.')')
        let g:hlPat[a:hlNum]   = []
    endif
endfunction

function s:HighlightClearBuffPriv(hlNum)
    call matchdelete(w:hlIdArr[a:hlNum])
    let w:hlIdArr[a:hlNum] = 0
endfunction

function s:HighlightCheckNum(hlNum)
    if a:hlNum >= s:TOTAL_HL_NUMBERS
        echoerr 'ERROR: Highlight number must be from 0 to 's:TOTAL_HL_NUMBERS-1'inclsive. Not'a:hlNum
        return 0
    endif
    return 1
endfunction

function HighlightSearch(...)
    let searchStr = call('HighlightPattern', a:000)
    call UserSerach(searchStr)
endfunction

function HighlightPattern(...)
    let idxs = []
    if a:0 == 0
        let idxs = range(s:TOTAL_HL_NUMBERS)
    else
        for aIdx in range(1, a:0) "range stopes AFTER
            call add(idxs,eval('a:'.aIdx))
        endfor
    endif
    let pattern = ''
    for idx in idxs
        if len(g:hlPat[idx]) > 0
            let idxPattern = FlatternStrArr(g:hlPat[idx], s:REGEX_OR)
            if len(pattern) > 0 
                let pattern .= s:REGEX_OR
            endif
            let pattern .= idxPattern
        endif
    endfor
    return pattern
endfunction

function UserSerach(searchStr)
    let @/ = a:searchStr
    "exe 'normal /'.a:searchStr."\<CR>" "Only adds serach to history
endfunction

"}}}

