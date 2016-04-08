"===============================================================================
"
"          File:  update-author.vim
"
"   Description:  
"
"   VIM Version:  7.0+
"        Author:  ShadowStar, <orphen.leiliu@gmail.com>
"  Organization:  Gmail
"       Version:  1.0
"       Created:  04/08/16 14:36:13
"   Last Change:  04/08/16 17:31:29
"      Revision:  ---
"       License:  Copyright (c) year 2016, Lei Liu
"===============================================================================

if exists("g:loaded_update_author")
    finish
endif
let g:loaded_update_author = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:update_author_stamp_leader')
    let s:author_stamp_leader = ['Author:']
else
    let s:author_stamp_leader = g:update_author_stamp_leader
endif

if !exists('g:update_company_stamp_leader')
    let s:company_stamp_leader = ['Organization:', 'Company:']
else
    let s:company_stamp_leader = g:update_company_stamp_leader
endif

if !exists("g:update_author_begin_line")
    let s:begin_line = 0
else
    let s:begin_line = g:update_author_begin_line
endif

if !exists('g:update_author_end_line')
    let s:end_line = 30
else
    let s:end_line = g:update_author_end_line
endif

if !exists('g:update_author_enable')
    let s:update_author_enable = 1
else
    let s:update_author_enable = g:update_author_enable
endif

fun Update_author_update()
    if ! &modifiable
        return
    endif
    if ! s:update_author_enable
        return
    endif
    let bufmodified = getbufvar('%', '&mod')
    if ! bufmodified
        return
    endif
    let name = system('git config user.name')[:-2]
    let email = system('git config user.email')[:-2]
    let author = ''
    let com = ''
    if strlen(name)
        let author = substitute(name, '\(\<\w\+\>\)', '\u\1', 'g')
    endif
    if strlen(email)
        let com = substitute(email, '.\+@\([^\.]\+\).\+', '\1', '')
        if !strlen(author)
            let user = substitute(email, '\([^@]\+\).\+', '\1', '')
            let author = substitute(user, '\(\<\w\+\>\)', '\u\1', 'g')
        endif
        let author = author.', <'.email.'>'
    endif
    let pos = line('.').' | normal! '.virtcol('.').'|'
    exe s:begin_line
    for auth in s:author_stamp_leader
        let line_num = search(auth, '', s:end_line)
        if line_num > 0
            let line = getline(line_num)
            let line = substitute(line, auth . '\zs.*', '  '.author, '')
            call setline(line_num, line)
        endif
    endfor
    if strlen(com)
        let com = substitute(com, '\(\<\w\+\>\)', '\u\1', '')
	for company in s:company_stamp_leader
            let line_num = search(company, '', s:end_line)
            if line_num > 0
                let line = getline(line_num)
                let line = substitute(line, company . '\zs.*', '  '.com, '')
                call setline(line_num, line)
            endif
        endfor
    endif
    exe pos
endf
fun Update_author_toggle()
    let s:update_author_enable = !s:update_author_enable
endf

autocmd BufWritePre * call Update_author_update()

com! -nargs=0 UpdateAuthorToggle call Update_author_toggle()

let &cpo = s:save_cpo
unlet s:save_cpo

