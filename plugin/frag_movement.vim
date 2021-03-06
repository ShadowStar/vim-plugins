" diff_movement.vim: Movement over diff hunks with ]] etc.
"
" DEPENDENCIES:
"   - CountJump.vim, CountJump/Motion.vim, CountJump/TextObjects.vim autoload
"     scripts.
"
" Copyright: (C) 2009-2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.01.005	21-Sep-2011	Avoid use of s:function() by using autoload
"				function name.
"   1.00.004	03-Aug-2010	FIX: Multiple [count] text objects were broken
"				by the jump to the actual diff hunk start; must
"				only do a one-step jump there.
"	003	02-Aug-2010	Tested with new CountJump 1.20, adapted and
"				improved s:JumpToHunkEnd().
"	002	16-Jul-2010	BUG: s:JumpToHunkEnd() returned line number, not
"				position pair.
"				BUG: Outer hunk selected next @@...@@ hunk
"				header line in some cases. Needed to accommodate
"				'nostartofline' setting in the end position
"				correction (:normal 0).
"	001	12-Feb-2009	file creation from vim_movement.vim

" Avoid installing when in unsupported Vim version.
if v:version < 700
    finish
endif
let s:save_cpo = &cpo
set cpo&vim

"			Move around diff hunks:
"]]			Go to [count] next start of a diff hunk.
"][			Go to [count] next end of a diff hunk.
"[[			Go to [count] previous start of a diff hunk.
"[]			Go to [count] previous end of a diff hunk.

" There are three branches for the three different diff types:
"   traditional | context | unified
let s:diffHunkHeaderPattern = '^\%(\d\+\%(,\d\+\)\=[cda]\d\+\>\|\*\{4,}\n\*\*\* \|@@.*@@\)'

" For the pattern-to-end, search for the line above the hunk header pattern, but
" exclude lines of the diff header (starting with '--- ' ,but not matching
" '--- .* ----', the separator) in context diffs and '+++ ' in unified diffs;
" traditional diffs have no header).
" Also match the start of a new diff file
" - starting with '*** 'in context diffs, but only if the preceding line doesn't
"   start with:
"   - many ****'s, or it's the separator of a context diff
"   - many ==='s, or it's the separator after an Index:
"   - 'diff ', or it's the echoed diff command as a separator.
" - starting with '--- ' in unified diffs, but not matching '--- .* ----', the
"   separator in a context diff, but only if the preceding line doesn't start
"   with:
"   - '*** ', or it's a context diff
"   - many '==='s, or it's the separator after an Index:
"   - 'diff ', or it's the echoed diff command as a separator.
" - or a line starting with 'Index: ' or 'diff '
" Finally match the last line of the buffer, because there's no special "end of
" diff" line, diffs just end after the last hunk.
let s:diffHunkEndPattern = join(
\   [
\	'^\%(--- .*\%( ----\)\@<!$\|+++ \)\@!.*\n' . s:diffHunkHeaderPattern,
\	'^\%(\*\{4,}\|=\{10,}\|diff \)\@!.*\n^\*\*\* ',
\	'^\%(\*\*\* \|=\{10,}\|diff \)\@!.*\n^--- .*\%( ----\)\@<!$',
\	'^.*\nIndex: ',
\	'^.*\ndiff ',
\	'^.*\%$'
\   ], '\|'
\)

call CountJump#Motion#MakeBracketMotion('<buffer>', '', '',
\   s:diffHunkHeaderPattern,
\   s:diffHunkEndPattern,
\   0
\)

"ih			"inner hunk" text object, select [count] hunk contents.
"ah			"a hunk" text object, select [count] hunks, including
"			the header.
" Note: For context diffs, these selections are off by one or a few lines.
function! s:diff_movement_JumpToHunkBegin( count, isInner )
    " Enable selection of inner hunk even if the cursor is positioned on the
    " hunk header.
    if a:isInner
	normal! j0
    endif

    let l:pos = CountJump#CountSearch(a:count, [s:diffHunkHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])
    if l:pos == [0, 0] | return l:pos | endif

    if a:isInner
	normal! j0
    endif
    return l:pos
endfunction
function! s:diff_movement_JumpToHunkEnd( count, isInner )
    " Due to the multi-line pattern, we somehow must navigate to the actual
    " start of the diff hunk. This only differs from the cursor position (after
    " the diff hunk header, position 1) by less than one full line, if at all,
    " but is significant for certain hunks.
    call CountJump#CountSearch(1, [s:diffHunkHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])

    let l:pos = CountJump#CountSearch(a:count, [s:diffHunkEndPattern, 'W' . (a:isInner ? '' : 'e')])

    if ! a:isInner && line('.') < line('$')
	normal! k0
	if getline('.') =~# '\*\{4,}$'
	    " Further adaptation to exclude the context diff separator line in
	    " an outer text object.
	    normal! k0
	endif
    endif
    return l:pos
endfunction

call CountJump#TextObject#MakeWithJumpFunctions('<buffer>', 'h', 'aI', 'V',
\   function('s:diff_movement_JumpToHunkBegin'),
\   function('s:diff_movement_JumpToHunkEnd'),
\)

unlet s:diffHunkHeaderPattern
unlet s:diffHunkEndPattern

let s:diffFileHeaderPattern = '^\%(--- .*\n+++ .*\n@@ -.* \+.* @@\|\*\*\* .*\n--- .*\n\*{15}\)'
let s:diffFileEndPattern = join(
\   [
\	'^.*\n' . s:diffFileHeaderPattern,
\	'^.*\%$'
\   ], '\|'
\)

call CountJump#Motion#MakeBracketMotion('<buffer>', 'd', 'D',
\   s:diffFileHeaderPattern,
\   s:diffFileEndPattern,
\   0
\)

function! s:diff_file_movement_JumpToHunkBegin( count, isInner )
    " Enable selection of inner hunk even if the cursor is positioned on the
    " hunk header.
    if a:isInner
	normal! j0
    endif

    let l:pos = CountJump#CountSearch(a:count, [s:diffFileHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])
    if l:pos == [0, 0] | return l:pos | endif

    if a:isInner
	normal! j0
    endif
    return l:pos
endfunction
function! s:diff_file_movement_JumpToHunkEnd( count, isInner )
    " Due to the multi-line pattern, we somehow must navigate to the actual
    " start of the diff hunk. This only differs from the cursor position (after
    " the diff hunk header, position 1) by less than one full line, if at all,
    " but is significant for certain hunks.
    call CountJump#CountSearch(1, [s:diffFileHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])

    let l:pos = CountJump#CountSearch(a:count, [s:diffFileEndPattern, 'W' . (a:isInner ? '' : 'e')])

    if ! a:isInner && line('.') < line('$')
	normal! k0
	if getline('.') =~# '\*\{4,}$'
	    " Further adaptation to exclude the context diff separator line in
	    " an outer text object.
	    normal! k0
	endif
    endif
    return l:pos
endfunction

call CountJump#TextObject#MakeWithJumpFunctions('<buffer>', 'h', 'aI', 'V',
\   function('s:diff_file_movement_JumpToHunkBegin'),
\   function('s:diff_file_movement_JumpToHunkEnd'),
\)

unlet s:diffFileHeaderPattern
unlet s:diffFileEndPattern

let s:gitHunkHeaderPattern = '^\%(From\|commit\)\s\+\x\{40\}'

let s:gitHunkEndPattern = join(
\   [
\	'^.*\n' . s:gitHunkHeaderPattern,
\	'^.*\%$'
\   ], '\|'
\)

call CountJump#Motion#MakeBracketMotion('<buffer>', 'g', 'G',
\   s:gitHunkHeaderPattern,
\   s:gitHunkEndPattern,
\   0
\)

function! s:git_movement_JumpToHunkBegin( count, isInner )
    " Enable selection of inner hunk even if the cursor is positioned on the
    " hunk header.
    if a:isInner
	normal! j0
    endif

    let l:pos = CountJump#CountSearch(a:count, [s:gitHunkHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])
    if l:pos == [0, 0] | return l:pos | endif

    if a:isInner
	normal! j0
    endif
    return l:pos
endfunction
function! s:git_movement_JumpToHunkEnd( count, isInner )
    " Due to the multi-line pattern, we somehow must navigate to the actual
    " start of the diff hunk. This only differs from the cursor position (after
    " the diff hunk header, position 1) by less than one full line, if at all,
    " but is significant for certain hunks.
    call CountJump#CountSearch(1, [s:gitHunkHeaderPattern, 'bcW' . (a:isInner ? 'e' : '')])

    let l:pos = CountJump#CountSearch(a:count, [s:gitHunkEndPattern, 'W' . (a:isInner ? '' : 'e')])

    if ! a:isInner && line('.') < line('$')
	normal! k0
	if getline('.') =~# '\*\{4,}$'
	    " Further adaptation to exclude the context diff separator line in
	    " an outer text object.
	    normal! k0
	endif
    endif
    return l:pos
endfunction

call CountJump#TextObject#MakeWithJumpFunctions('<buffer>', 'h', 'aI', 'V',
\   function('s:git_movement_JumpToHunkBegin'),
\   function('s:git_movement_JumpToHunkEnd'),
\)

unlet s:gitHunkHeaderPattern
unlet s:gitHunkEndPattern

let s:vimHunkHeaderPattern = '^\s*fu\%[nction]\>'
let s:vimHunkEndPattern = '^\s*endf*\%[unction]\>'

"			Move around Vim functions:
"]m			Go to [count] next start of a function.
"]M			Go to [count] next end of a function.
"[m			Go to [count] previous start of a function.
"[M			Go to [count] previous end of a function.

call CountJump#Motion#MakeBracketMotion('<buffer>', 'm', 'M', s:vimHunkHeaderPattern, s:vimHunkEndPattern, 0)

"im			"inner method" text object, select [count] function contents.
"am			"a method" text object, select [count] functions, including
"			the function definition and 'endfunction'.
call CountJump#TextObject#MakeWithCountSearch('<buffer>', 'm', 'ai', 'V', s:vimHunkHeaderPattern, s:vimHunkEndPattern)

unlet s:vimHunkHeaderPattern
unlet s:vimHunkEndPattern

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
