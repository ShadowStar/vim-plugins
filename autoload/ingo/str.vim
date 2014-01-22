" ingo/str.vim: String functions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.003	23-Dec-2013	Add ingo#str#StartsWith() and
"				ingo#str#EndsWith().
"   1.011.002	26-Jul-2013	Add ingo#str#Reverse().
"   1.009.001	19-Jun-2013	file creation

function! ingo#str#Trim( string )
"******************************************************************************
"* PURPOSE:
"   Remove all leading and trailing whitespace from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"* RETURN VALUES:
"   a:string with leading and trailing whitespace removed.
"******************************************************************************
    return substitute(a:string, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

function! ingo#str#Reverse( string )
    return join(reverse(split(a:string, '\zs')), '')
endfunction

function! ingo#str#StartsWith( string, substring )
    return (strpart(a:string, 0, len(a:substring)) ==# a:substring)
endfunction
function! ingo#str#EndsWith( string, substring )
    return (strpart(a:string, len(a:string) - len(a:substring)) ==# a:substring)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
