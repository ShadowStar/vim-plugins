" oops_trace.vim - Use tag-style lookups on Linux kernel oops backtraces.
"
" Maintainer:   Ross Zwisler <zwislerNOSPAM@gmail.com>
"
" This script lets you use tag-style lookups (i.e. C-] ) on Linux kernel oops
" stack traces.  For this to work, you need the following:
"
" 1) The log file with the stack trace needs to be recognized as having
"    filetype=messages, which is hopefully the default.  If not, run 
"    'set filetype=messages'.
" 2) You need to have built your kernel with debug symbols
"    (CONFIG_DEBUG_INFO=y).
" 3) Vim needs to have its PWD in your Linux build directory, or you need to
"    set up the g:oops_path global variable to your build directory.  i.e.:
"    let g:oops_path='/home/myuser/linux-kernel'

function! s:FakeTagJump(file, line)
        let file=a:file
        let tmpfile = tempname()
        let tag=substitute(tmpfile, '/','', 'g')
        let tagline = tag . "\t".fnamemodify(file, ":p")."\t".a:line
        call writefile([tagline], tmpfile)
        exe "set tags+=" . tmpfile
        exe "tag " . tag
        call system("rm " . tmpfile)
        exe "set tags-=" . tmpfile  
endfun

function! s:GotoLine(file)
	if (filereadable(a:file))
            echo "file " . a:file . " not readable"
            return
	endif

	let names =  matchlist( a:file, '\([^:]\+\):\(\d\+\)')

	if empty(names)
            echo "no matching files"
            return
	endif

	let file_name = names[1]
	let line_num  = names[2] == ''? '0' : names[2]

	if filereadable(file_name)
            call s:FakeTagJump(file_name, line_num)
            exec "normal! zz"
        else
            echo "file " . file_name . " not readable"
	endif
endfunction

function! OopsTrace(line)
    let symbols = matchlist(a:line, '\(\(\w\|\.\)\+\)+\(\w\+\)/\w\+\( \[\(\w\+\)\]\)\?')

    if empty(symbols)
        return
    endif

    let function = symbols[1]
    let offset   = symbols[3]
    let module   = symbols[5]

    if exists("g:oops_path")
        let oops_path = g:oops_path
    else
        let oops_path = getcwd()
    endif

    if !filereadable(oops_path . '/vmlinux')
        echo "Can't find Linux build files - please check " . oops_path
        return
    endif

    if module == ''
        let module = oops_path . "/vmlinux"
    else
        let module = substitute(module, "[-_]", "?", "g")
        let module = system("find " . oops_path . " -name " . module . ".ko")
        if module == ""
            echo "Kernel module not found"
            return
        endif
        let module = substitute(module, '\n$', '', '')
    endif

    if offset != 0
        " this is necssary so we return to the caller, not the next
        " instruction to be executed after return
        let offset = offset - 1
    endif

    let func_offset_cmd = "nm ". module . '| awk "/ [Tt] ' . function . '\$/ { print \"0x\" \$1; }" | head -n1'
    let func_offset = system(func_offset_cmd)

    if func_offset == ""
        echo "Symbol lookup failed"
        return
    endif

    let abs_offset = system("printf 0x%x $((" . func_offset . "+" . offset . "))")

    let location = system('addr2line -e ' . module . ' ' . abs_offset)
    let location = substitute(location, '\n$', '', '')

    if location == '??:?'
        echo "Was your kernel built with debug symbols?"
    else
        call s:GotoLine(location)
    endif
endfunction

au filetype messages nnoremap <buffer> <silent> <C-]> :call OopsTrace(getline(line('.')))<CR>
