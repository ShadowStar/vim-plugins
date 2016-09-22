" File: update-last.vim
" Author: ShadowStar, <orphen.leiliu@gmail.com>
" Create Time: 2013-12-04 19:36:21 CST
" Last Change: 09/21/2016 22:12:04
" Description: Automatic update Last Change time & author

if exists("g:loaded_update_last")
    finish
endif
let g:loaded_update_last = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:update_last_time_stamp_leader')
    let s:time_stamp_leader = 'Last Change:'
else
    let s:time_stamp_leader = g:update_last_time_stamp_leader
endif

if !exists('g:update_last_time_format')
    let s:time_format = '%Y-%m-%d %H:%M:%S %Z'
else
    let s:time_format = g:update_last_time_format
endif

if !exists('g:update_last_author_stamp_leader')
    let s:author_stamp_leader = ['Author:', 'Maintainer:']
else
    let s:author_stamp_leader = g:update_last_author_stamp_leader
endif

if !exists('g:update_last_company_stamp_leader')
    let s:company_stamp_leader = ['Organization:', 'Company:']
else
    let s:company_stamp_leader = g:update_last_company_stamp_leader
endif

if !exists("g:update_last_begin_line")
    let s:begin_line = 0
else
    let s:begin_line = g:update_last_begin_line
endif

if !exists('g:update_last_end_line')
    let s:end_line = 20
else
    let s:end_line = g:update_last_end_line
endif

if !exists('g:update_last_enable')
    let s:update_enable = 1
else
    let s:update_enable = g:update_last_enable
endif
if !exists('g:update_locale')
    let s:update_locale = 'en_US.UTF-8'
else
    let s:update_locale = g:update_locale
endif

fun s:Update_last_time()
    if ! &modifiable
        return
    endif
    let bufmodified = getbufvar('%', '&mod')
    if ! bufmodified
        return
    endif
    let save_lang = v:lc_time
    silent exe 'language time ' . s:update_locale
    let pos = line('.').' | normal! '.virtcol('.').'|'
    exe s:begin_line
    let line_num = search(s:time_stamp_leader . '\c', '', s:end_line)
    if line_num > 0
        let line = getline(line_num)
        let line = substitute(line, s:time_stamp_leader . '\c\zs.*', ' ' . strftime(s:time_format), '')
        call setline(line_num, line)
    endif
    silent exe 'language time ' . save_lang
    exe pos
endf

fun s:Update_last_author()
    if ! &modifiable
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
        let line_num = search(auth.'\c', '', s:end_line)
        if line_num > 0
            let line = getline(line_num)
            let line = substitute(line, auth . '\c\zs.*', ' '.author, '')
            call setline(line_num, line)
        endif
    endfor
    if strlen(com)
        let com = substitute(com, '\(\<\w\+\>\)', '\u\1', '')
	for company in s:company_stamp_leader
            let line_num = search(company . '\c', '', s:end_line)
            if line_num > 0
                let line = getline(line_num)
                let line = substitute(line, company . '\c\zs.*', ' '.com, '')
                call setline(line_num, line)
            endif
        endfor
    endif
    exe pos
endf

fun s:Update_last()
    if ! s:update_enable
        return
    endif
    call s:Update_last_time()
    call s:Update_last_author()
endf

fun s:Update_last_toggle()
    let s:update_enable = !s:update_enable
endf

autocmd BufWritePre * call s:Update_last()

com! -nargs=0 UpdateLastToggle call s:Update_last_toggle()
com! -nargs=0 UpdateLast call s:Update_last()

let &cpo = s:save_cpo
unlet s:save_cpo

