" diffchar.vim: Highlight the exact differences, based on characters and words
"
"  ____   _  ____  ____  _____  _   _  _____  ____   
" |    | | ||    ||    ||     || | | ||  _  ||  _ |  
" |  _  || ||  __||  __||     || | | || | | || | ||  
" | | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
" | |_| || ||  __||  __||  |   |     ||     ||  __  |
" |     || || |   | |   |  |__ |  _  ||  _  || |  | |
" |____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
"
" Last Change:	2017/11/26
" Version:		7.31
" Author:		Rick Howe <rdcxy754@ybb.ne.jp>

let s:save_cpo = &cpoptions
set cpo&vim

" Vim feature, function, event and patch number which this plugin depends on
" patch-7.4.682:  diff highlight not hidden by matchadd()
" patch-7.4.1895: Window-ID available
" patch-8.0.736:  OptionSet event triggered with diff option
" patch-8.0.1038: strikethrough attribute available
" patch-8.0.1160: gettabvar() fixed not to return empty
" patch-8.0.1204: QuitPre fixed to represent affected buffer in <abuf>
let s:VF = {
	\'QuitPre': exists('##QuitPre'),
	\'TextChanged': exists('##TextChanged'),
	\'TextChangedI': exists('##TextChangedI'),
	\'MatchaddPos': exists('*matchaddpos'),
	\'GUIColors': has('gui_running') ||
									\has('termguicolors') && &termguicolors,
	\'Timers': has('timers'),
	\'DiffHLUnhidden': has('patch-7.4.682'),
	\'WindowID': has('patch-7.4.1895'),
	\'DiffOptionSet': has('patch-8.0.736'),
	\'StrikeAttr': has('patch-8.0.1038') &&
					\(has('gui_running') || !empty(&t_Ts) && !empty(&t_Te)),
	\'GettabvarFixed': has('patch-8.0.1160'),
	\'QuitPreAbufFixed': has('patch-8.0.1204')}

function! s:InitializeDiffChar()
	if min(tabpagebuflist()) == max(tabpagebuflist())
		call s:EchoWarning('Need more buffers displayed in this tab page!')
		return -1
	endif

	" select current window and next (diff mode if available) window
	" whose buffer is different
	let nwin = filter(range(winnr() + 1, winnr('$')) + range(1, winnr() - 1),
											\'winbufnr(v:val) != bufnr("%")')
	let dwin = filter(copy(nwin), 'getwinvar(v:val, "&diff")')
	let swin = {'1': winnr(), '2': !empty(dwin) ? dwin[0] : nwin[0]}
	" check if both or either of selected windows have already been DChar
	" highlighted in other tab pages
	let sbuf = map(values(swin), 'winbufnr(v:val)')
	for tp in filter(range(tabpagenr() + 1, tabpagenr('$')) +
			\range(1, tabpagenr() - 1), '!empty(s:Gettabvar(v:val, "DChar"))')
		if !empty(filter(map(tabpagebuflist(tp),
			\'[s:VF.WindowID ? win_getid(v:key + 1, tp) : v:key + 1, v:val]'),
					\'index(values(s:GetDiffCharWID(tp)), v:val[0]) != -1 &&
											\index(sbuf, v:val[1]) != -1'))
			call s:EchoWarning('Can not show due to both/either buffer
									\ highlighted in tab page ' . tp . '!')
			return -1
		endif
	endfor

	" define a DiffChar dictionary on this tab page
	let t:DChar = {}
	call s:SetDiffCharWID(swin)

	let cwin = s:GetWID()
	" find corresponding DiffChange/DiffText lines on diff mode windows
	if empty(filter(values(swin), '!getwinvar(v:val, "&diff")'))
		let t:DChar.dml = {}
		let [dc, dt] = [hlID(s:DCharHL.c), hlID(s:DCharHL.t)]
		if has('nvim') && s:IsDiffHLIDCorrect() == 0
			let [dc, dt] -= [1, 1]
		endif
		for k in [1, 2]
			call s:GotoWID(s:GetDiffCharWID()[k])
			let t:DChar.dml[k] = filter(range(1, line('$')),
								\'index([dc, dt], diff_hlID(v:val, 1)) != -1')
			if empty(t:DChar.dml[k])
				let t:DChar.dml[k == 1 ? 2 : 1] = []
				break
			endif
		endfor
	endif
	" set a difference unit updating on this tab page
	" and a record of line values and number of total lines
	let t:DChar.dut = get(t:, 'DiffUpdate', g:DiffUpdate)
	if t:DChar.dut
		let t:DChar.dul = {}	" number of lines for update
		for k in [1, 2]
			call s:GotoWID(s:GetDiffCharWID()[k])
			let t:DChar.dul[k] = line('$')
		endfor
	endif
	" set a difference unit pair view while moving cursor
	let t:DChar.dpv = get(t:, 'DiffPairVisible', g:DiffPairVisible)
	if t:DChar.dpv
		let t:DChar.cpi = {}	" pair cursor position and mid
		let t:DChar.clc = {}	" previous cursor line/col
		for k in [1, 2]
			call s:GotoWID(s:GetDiffCharWID()[k])
			let t:DChar.clc[k] = [line('.'), col('.'), b:changedtick]
		endfor
	endif
	call s:GotoWID(cwin)

	" set ignorecase and ignorespace flags
	let t:DChar.igc = (&diffopt =~ 'icase')
	let t:DChar.igs = (&diffopt =~ 'iwhite')
	" set line and its highlight id record
	let t:DChar.mid = {'1': {}, '2': {}}
	" set highlighted lines and columns record
	let t:DChar.hlc = {'1': {}, '2': {}}
	" set a difference unit type on this tab page and set a split pattern
	let du = get(t:, 'DiffUnit', g:DiffUnit)
	if du == 'Char'				" any single character
		let t:DChar.upa = t:DChar.igs ? '\%(\s\+\|.\)\zs' : '\zs'
	elseif du == 'Word2'		" non-space and space words
		let t:DChar.upa = '\%(\s\+\|\S\+\)\zs'
	elseif du == 'Word3'		" \< or \> boundaries
		let t:DChar.upa = '\<\|\>'
	elseif du =~ '^CSV(.\+)$'	" split characters
		let s = escape(du[4 : -2], '^-]')
		let t:DChar.upa = '\%([^'. s . ']\+\|[' . s . ']\)\zs'
	elseif du =~ '^SRE(.\+)$'	" split regular expression
		let t:DChar.upa = du[4 : -2]
	else
		" \w\+ word and any \W character
		let t:DChar.upa = t:DChar.igs ?
								\'\%(\s\+\|\w\+\|\W\)\zs' : '\%(\w\+\|\W\)\zs'
		if du != 'Word1'
			call s:EchoWarning('Not a valid difference unit type.
													\ Use "Word1" instead.')
		endif
	endif
	" set a time length (ms) to apply this plugin's builtin function first
	let t:DChar.dst = executable('diff') ?
							\get(t:, 'DiffSplitTime', g:DiffSplitTime) : 1/0
	" set a diff mode synchronization flag
	let t:DChar.dms = get(t:, 'DiffModeSync', g:DiffModeSync)
	" set a difference matching colors on this tab page
	let t:DChar.hgp = [s:DCharHL.T]
	let dc = get(t:, 'DiffColors', g:DiffColors)
	if 1 <= dc && dc <= 3
		let t:DChar.hgp += ['NonText', 'Search', 'VisualNOS',
						\'ErrorMsg', 'MoreMsg', 'TabLine', 'Title',
						\'StatusLine', 'WarningMsg', 'Conceal', 'SpecialKey',
						\'ColorColumn', 'ModeMsg', 'SignColumn', 'Question']
										\[: (dc == 1 ? 2 : dc == 2 ? 6 : -1)]
	elseif dc == 100
		let hl = {}
		let id = 1
		while 1
			let nm = synIDattr(id, 'name')
			if empty(nm) | break | endif
			if index(values(s:DCharHL), nm) == -1 && id == synIDtrans(id) &&
				\!empty(filter(['fg', 'bg', 'sp', 'bold', 'italic', 'reverse',
							\'inverse', 'standout', 'underline', 'undercurl',
						\'strikethrough'], '!empty(synIDattr(id, v:val))'))
				let hl[reltimestr(reltime())[-2 :] . id] = nm
			endif
			let id += 1
		endwhile
		let t:DChar.hgp += values(hl)
	endif
endfunction

function! diffchar#ToggleDiffChar(lines)
	if exists('t:DChar')
		for k in [1, 2, 0]
			if k == 0 | return | endif
			if s:GetDiffCharWID()[k] == s:GetWID() | break | endif
		endfor
		for hl in keys(t:DChar.hlc[k])
			if index(a:lines, eval(hl)) != -1
				call diffchar#ResetDiffChar(a:lines)
				return
			endif
		endfor
	endif
	call diffchar#ShowDiffChar(a:lines)
endfunction

function! diffchar#ShowDiffChar(...)
	if !exists('t:DChar') && s:InitializeDiffChar() == -1 | return | endif
	let init = (index(values(t:DChar.hlc), {}) != -1)

	let cwin = s:GetWID()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if s:GetDiffCharWID()[k] == cwin | break | endif
	endfor

	let lines = (a:0 == 0) ? range(1, line('$')) : a:1
	let [d1, d2] = exists('t:DChar.dml') ?
					\s:DiffModeLines(k, lines) : [copy(lines), copy(lines)]

	for k in [1, 2]
		call filter(d{k}, '!has_key(t:DChar.hlc[k], v:val)')
		let bn = winbufnr(s:GetDiffCharWID()[k])
		let u{k} = filter(map(copy(d{k}),
						\'get(getbufline(bn, v:val), 0, -1)'), 'v:val != -1')
		let n{k} = len(u{k})
		if n{k} < len(d{k}) | unlet d{k}[n{k} :] | endif
	endfor

	if n1 == n2 | let ln = n1
	elseif n1 < n2 | unlet d2[n1 :] | let ln = n1
	else | unlet d1[n2 :] | let ln = n2
	endif

	let save_igc = &ignorecase | let &ignorecase = t:DChar.igc

	let uu = []
	for n in range(ln - 1, 0, -1)
		if u1[n] == u2[n]
			unlet d1[n] | unlet d2[n]
		else
			let uu =
				\[[split(u1[n], t:DChar.upa), split(u2[n], t:DChar.upa)]] + uu
		endif
	endfor
	if empty(uu)
		if init | call s:SetDiffCharWID({}) | unlet t:DChar | endif
		let &ignorecase = save_igc
		return
	endif

	let [lc1, lc2] = [{}, {}]
	let ln = 0
	for fn in ['ApplyBuiltinFunction', 'ApplyDiffCommand']
		" apply the builtin function first, if timeout, the diff command next
		for es in s:{fn}(uu[ln :])
			let [lc1[d1[ln]], lc2[d2[ln]]] = s:GetDiffUnitPos(es, uu[ln])
			let ln += 1
		endfor
	endfor

	let &ignorecase = save_igc

	for k in [1, 2]
		call s:GotoWID(s:GetDiffCharWID()[k])
		call s:HighlightDiffChar(k, filter(lc{k}, '!empty(v:val)'))
	endfor
	call s:GotoWID(cwin)

	if index(values(t:DChar.hlc), {}) == -1
		if t:DChar.dpv
			call s:ShowDiffCharPair(s:GetDiffCharWID()[1] == cwin ? 1 : 2)
		endif
		if init			" set event when DChar HL is newly defined
			call s:ToggleDiffCharEvent(1)
			if s:VF.DiffHLUnhidden | call s:ToggleDiffHL(1) | endif
		endif
	else
		call s:SetDiffCharWID({})
		unlet t:DChar
	endif
endfunction

function! s:ApplyBuiltinFunction(uu)
	let nes = []
	let time = [t:DChar.dst]
	for [u1, u2] in a:uu
		if t:DChar.igs
			" convert \s\+ to a single one and remove trailing space and unit
			for k in [1, 2]
				let u{k} = map(copy(u{k}),
									\'substitute(v:val, "\\s\\+", " ", "g")')
				let u{k}[-1] = substitute(u{k}[-1], '\s\+$', '', '')
				if empty(u{k}[-1]) | unlet u{k}[-1] | endif
			endfor
		endif
		let es = s:TraceDiffChar(u1, u2, time)
		if es == '*' | break | endif	" if timeout while tracing, break here
		let nes += [es]
	endfor
	return nes
endfunction

function! s:ApplyDiffCommand(uu)
	let ln = len(a:uu)
	if ln == 0 | return [] | endif
	" prepare 2 input files for diff
	for k in [1, 2]
		" add '<number>:' at the beginning of each unit
		let g{k} = ['']			" add a dummy to avoid 1st null unit error
		let p{k} = []			" a unit range of each line
		let s = 1
		for n in range(ln)
			let g = map(copy(a:uu[n][k - 1]), 'n . ":" . v:val')
			let g{k} += g
			let e = s + len(g) - 1
			let p{k} += [[s, e]]
			let s = e + 1
		endfor
		let f{k} = tempname() | call writefile(g{k}, f{k})
	endfor
	" initialize a list of edit symbols [=_+-#|] for each unit
	for [k, q] in [[1, '='], [2, '_']]
		let g{k} = repeat([q], len(g{k}))
	endfor
	" call diff and assign edit symbols [=+-#] to each unit
	let opt = '-a --binary '
	if t:DChar.igc | let opt .= '-i ' | endif
	if t:DChar.igs | let opt .= '-b ' | endif
	let save_stmp = &shelltemp | let &shelltemp = 0
	let dout = system('diff ' . opt . f1 . ' ' . f2)
	let &shelltemp = save_stmp
	for [l1, op, l2] in map(filter(split(dout, '\n'), 'v:val[0] !~ "[<>-]"'),
							\'split(substitute(v:val, "[acd]", " & ", ""))')
		for [k, r, c] in [[1, 'a', '-'], [2, 'd', '+']]
			let [s, e] = (l{k} =~ ',') ? split(l{k}, ',') : [l{k}, l{k}]
			let [s, e] -= [1, 1]
			if op == r
				let g{k}[s] .= '#'			" append add/del mark
			else
				let g{k}[s : e] = repeat([c], e - s + 1)
			endif
		endfor
	endfor
	" separate lines and divide units
	for [k, q] in [[1, '='], [2, '_']]
		call map(map(p{k}, '"|" . join(g{k}[v:val[0] : v:val[1]], "") . "|"'),
				\'split(v:val, "\\%(" . q . "\\+\\|[^" . q . "]\\+\\)\\zs")')
		call delete(f{k})
	endfor
	" get a list of edit script
	let nes = []
	for n in range(ln)
		let nes += [substitute(join(map(p1[n], 'v:val . p2[n][v:key]'), ''),
														\'[^=+-]', '', 'g')]
	endfor
	return nes
endfunction

function! s:GetDiffUnitPos(es, uu)
	let [u1, u2] = a:uu
	if empty(u1)
		return [[['d', [0, 0]]], [['a', [1, len(join(u2, ''))]]]]
	elseif empty(u2)
		return [[['a', [1, len(join(u1, ''))]]], [['d', [0, 0]]]]
	endif

	let [c1, c2] = [[], []]
	let [l1, l2, p1, p2] = [1, 1, 0, 0]
	for ed in split(a:es, '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			for k in [1, 2]
				let [l{k}, p{k}] +=
							\[len(join(u{k}[p{k} : p{k} + qn - 1], '')), qn]
			endfor
		else				" one or more '[+-]'
			let q1 = len(substitute(ed, '+', '', 'g'))
			let q2 = qn - q1
			for k in [1, 2]
				if 0 < q{k}
					let r = len(join(u{k}[p{k} : p{k} + q{k} - 1], ''))
					let h{k} = [l{k}, l{k} + r - 1]
					let [l{k}, p{k}] += [r, q{k}]
				else
					let h{k} = [
						\l{k} - (0 < p{k} ?
								\len(matchstr(u{k}[p{k} - 1], '.$')) : 0),
						\l{k} + (p{k} < len(u{k}) ?
								\len(matchstr(u{k}[p{k}], '^.')) - 1 : -1)]
				endif
			endfor
			let [r1, r2] = (q1 == 0) ? ['d', 'a'] :
										\(q2 == 0) ? ['a', 'd'] : ['c', 'c']
			let [c1, c2] += [[[r1, h1]], [[r2, h2]]]
		endif
	endfor
	return [c1, c2]
endfunction

function! s:TraceDiffChar(u1, u2, time)
	" An O(NP) Sequence Comparison Algorithm
	let [n1, n2] = [len(a:u1), len(a:u2)]
	if n1 == 0 && n2 == 0 | return ''
	elseif n1 == 0 | return repeat('+', n2)
	elseif n2 == 0 | return repeat('-', n1)
	endif

	" reverse to be M >= N
	let [M, N, u1, u2, e1, e2] = (n1 >= n2) ?
			\[n1, n2, a:u1, a:u2, '+', '-'] : [n2, n1, a:u2, a:u1, '-', '+']
	let D = M - N
	let fp = repeat([-1], M + N + 1)
	let etree = []		" [next edit, previous p, previous k]

	let st = reltime()
	let p = -1
	while fp[D] != M
		let a:time[0] -= eval(reltimestr(reltime(st))) * 1000
		if a:time[0] <= 0 | return '*' | endif	" if timeout, return with '*'
		let st = reltime()
		let p += 1
		let epk = repeat([[]], p * 2 + D + 1)
		for k in range(-p, D - 1, 1) + range(D + p, D, -1)
			let [x, epk[k]] = (fp[k - 1] < fp[k + 1]) ?
							\[fp[k + 1], [e1, k < D ? p - 1 : p, k + 1]] :
							\[fp[k - 1] + 1, [e2, k > D ? p - 1 : p, k - 1]]
			let y = x - k
			while x < M && y < N && u1[x] == u2[y]
				let epk[k][0] .= '='
				let [x, y] += [1, 1]
			endwhile
			let fp[k] = x
		endfor
		let etree += [epk]
	endwhile

	" create a shortest edit script (SES) from last p and k
	let ses = ''
	while 1
		let ses = etree[p][k][0] . ses
		if p == 0 && k == 0
			let a:time[0] -= eval(reltimestr(reltime(st))) * 1000
			return ses[1 :]		" remove the first entry
		endif
		let [p, k] = etree[p][k][1 : 2]
	endwhile
endfunction

function! diffchar#ResetDiffChar(...)
	if !exists('t:DChar') | return | endif

	let cwin = s:GetWID()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if s:GetDiffCharWID()[k] == cwin | break | endif
	endfor

	let lines = (a:0 == 0) ? map(keys(t:DChar.hlc[k]), 'eval(v:val)') : a:1
	let [d1, d2] = exists('t:DChar.dml') ?
					\s:DiffModeLines(k, lines) : [copy(lines), copy(lines)]

	for k in [1, 2]
		call filter(d{k}, 'has_key(t:DChar.hlc[k], v:val)')
		if empty(d{k}) | return | endif
	endfor
	for k in [1, 2]
		call s:GotoWID(s:GetDiffCharWID()[k])
		call s:ClearDiffChar(k, d{k})
	endfor
	call s:GotoWID(cwin)

	if t:DChar.dpv | call s:ClearDiffCharPair() | endif

	if index(values(t:DChar.hlc), {}) != -1
		" if no highlight remains, clear event and DChar
		call s:ToggleDiffCharEvent(0)
		if s:VF.DiffHLUnhidden | call s:ToggleDiffHL(0) | endif
		call s:SetDiffCharWID({})
		unlet t:DChar
	endif
endfunction

function! s:ToggleDiffCharEvent(on)
	" set or reset events for DChar buffer and tab page
	let ac = []
	for k in [1, 2]
		let bn = winbufnr(s:GetDiffCharWID()[k])
		if bn == -1 | continue | endif
		let bl = '<buffer=' . bn . '>'
		let ac += [['BufWinLeave', bl, 's:BufWinLeaveDiffChar(' . k . ')']]
		if s:VF.QuitPre
			let ac += [['QuitPre', bl, 's:QuitPreDiffChar(' . k . ')']]
		endif
		if s:VF.TextChanged && t:DChar.dut
			let ac += [['TextChanged', bl, 's:UpdateDiffChar(' . k . ')']]
		endif
		if s:VF.TextChangedI && t:DChar.dut
			let ac += [['TextChangedI', bl, 's:UpdateDiffChar(' . k . ')']]
		endif
		if t:DChar.dpv
			let ac += [['CursorMoved', bl, 's:ShowDiffCharPair(' . k . ')']]
		endif
	endfor
	let td = filter(map(range(1, tabpagenr() - 1) +
									\range(tabpagenr() + 1, tabpagenr('$')),
							\'s:Gettabvar(v:val, "DChar")'), '!empty(v:val)')
	if empty(td)
		let ac += [['WinEnter', '*', 's:SweepInvalidDiffChar()']]
		let ac += [['TabEnter', '*', 's:AdjustGlobalOption()']]
	endif
	if exists('t:DChar.dml') && t:DChar.dms
		if empty(filter(td, 'exists("v:val.dml") && v:val.dms'))
			if s:VF.DiffOptionSet
				let ac += [['OptionSet', 'diff', 's:ResetDiffModeSync()']]
			else
				" save command to recover later in SwitchDiffChar()
				let s:save_ch = a:on ? 's:ResetDiffModeSync()' : ''
				let ac += [['CursorHold', '*', s:save_ch]]
			endif
		endif
		if !s:VF.DiffOptionSet | call s:ChangeUTOption(a:on) | endif
	endif
	for [ev, pt, cd] in ac
		execute 'autocmd! diffchar ' . ev . ' ' . pt .
												\(a:on ? ' call ' . cd : '')
	endfor
endfunction

function! s:DiffModeLines(key, lines)
	let [d1, d2] = [[], []]
	for di in filter(map(copy(a:lines),
						\'index(t:DChar.dml[a:key], v:val)'), 'v:val != -1')
		let [d1, d2] += [[t:DChar.dml[1][di]], [t:DChar.dml[2][di]]]
	endfor
	return [d1, d2]
endfunction

function! s:HighlightDiffChar(key, lec)
	let lhc = {}
	for [l, ec] in items(a:lec)
		if has_key(t:DChar.mid[a:key], l) | continue | endif
		let t:DChar.hlc[a:key][l] = ec
		" collect all the column positions per highlight group
		let hc = {}
		let cn = 0
		for [e, c] in ec
			if e == 'c'
				let h = t:DChar.hgp[cn % len(t:DChar.hgp)]
				let cn += 1
			elseif e == 'a'
				let h = s:DCharHL.A
			elseif e == 'd'
				if c == [0, 0] | continue | endif		" ignore empty line
				let h = s:DCharHL.Z
			endif
			let hc[h] = get(hc, h, []) + [c]
		endfor
		let lhc[l] = hc
	endfor
	call s:MatchaddDiffChar(a:key, lhc)
endfunction

function! s:ClearDiffChar(key, lines)
	let mx = map(getmatches(), 'v:val.id')
	for l in a:lines
		call map(filter(t:DChar.mid[a:key][l], 'index(mx, v:val) != -1'),
														\'matchdelete(v:val)')
		unlet t:DChar.mid[a:key][l]
		unlet t:DChar.hlc[a:key][l]
	endfor
endfunction

function! s:UpdateDiffChar(key)
	if !exists('t:DChar') | return | endif

	" current DChar highlighted lines
	let dcl = map(keys(t:DChar.hlc[a:key]), 'eval(v:val)')
	" check how many lines were added/deleted and set it again
	let lnd = line('$') - t:DChar.dul[a:key]
	let t:DChar.dul[a:key] = line('$')

	if lnd == 0
		" no lines were added/deleted
		if mode() == 'i' || mode() == 'R'
			" select the current line only if any
			let udl = filter(copy(dcl), 'v:val == line(".")')
		else
			" compare current and previous contents and find changed lines
			let cct = map(copy(dcl), 'getline(v:val)')
			let wsv = winsaveview()
			if &cpoptions !~# 'u'
				let save_cp = &cpoptions | let &cpoptions .= 'u'
			endif
			noautocmd silent undo
			let udl = filter(copy(dcl), 'getline(v:val) !=# cct[v:key]')
			noautocmd silent undo
			if exists('save_cp') | let &cpoptions = save_cp | endif
			noautocmd call winrestview(wsv)
			" set with above 2 undos
			if t:DChar.dpv | let t:DChar.clc[a:key][2] = b:changedtick | endif
		endif
	else
		" select last changed and all the rest lines when added/deleted
		let udl = filter(copy(dcl), 'line("''.") <= v:val')
	endif

	if !empty(udl)
		" reset changed DChar lines anyway, and
		" only if no lines were added/deleted then show those lines again
		let cwin = s:GetWID()
		if lnd == 0 && udl == dcl
			" just in case all of DChar lines were changed,
			" add a dummy line not to clear DChar in ResetDiffChar()
			for k in [1, 2] | let t:DChar.hlc[k][0] = [] | endfor
		endif
		call s:GotoWID(s:GetDiffCharWID()[a:key])
		call diffchar#ResetDiffChar(udl)
		if lnd == 0
			call diffchar#ShowDiffChar(udl)
			if udl == dcl
				" delete the dummy and clear other related things
				for k in [1, 2] | unlet t:DChar.hlc[k][0] | endfor
				if index(values(t:DChar.hlc), {}) != -1
					" if no DChar lines left, clear event, HL and DChar
					call s:ToggleDiffCharEvent(0)
					if s:VF.DiffHLUnhidden | call s:ToggleDiffHL(0) | endif
					call s:SetDiffCharWID({})
					unlet t:DChar
				elseif s:VF.DiffHLUnhidden && !empty(filter(udl,
									\'!has_key(t:DChar.hlc[a:key], v:val)'))
					" if DChar lines remain and some changed lines became
					" identical so HL is not required, refresh Diff HL
					call s:ToggleDiffHL(-1)
				endif
			endif
		endif
		call s:GotoWID(cwin)
	endif
endfunction

function! diffchar#JumpDiffChar(dir, pos)
	" a:dir : 0 = backward, 1 = forward
	" a:pos : 0 = start, 1 = end
	if !exists('t:DChar') | return | endif

	for k in [1, 2, 0]
		if k == 0 | return | endif
		if s:GetDiffCharWID()[k] == s:GetWID() | break | endif
	endfor

	let [ln, co] = [line('.'), col('.')]
	if co == col('$')		" empty line
		if !a:dir | let co = 0 | endif
	else
		if a:pos
			let co += len(matchstr(getline(ln)[co - 1 :], '^.')) - 1
		endif
	endif

	if has_key(t:DChar.hlc[k], ln) &&
							\(a:dir ? co < t:DChar.hlc[k][ln][-1][1][a:pos] :
										\co > t:DChar.hlc[k][ln][0][1][a:pos])
		" found in the current line
		let hc = filter(map(copy(t:DChar.hlc[k][ln]), 'v:val[1][a:pos]'),
										\a:dir ? 'co < v:val' : 'co > v:val')
		let co = hc[a:dir ? 0 : -1]
	else
		" try to find in the prev/next highlighted line
		let hl = filter(map(keys(t:DChar.hlc[k]), 'eval(v:val)'),
										\a:dir ? 'ln < v:val' : 'ln > v:val')
		if empty(hl) | return | endif	" not found
		let ln = a:dir ? min(hl) : max(hl)
		let co = t:DChar.hlc[k][ln][a:dir ? 0 : -1][1][a:pos]
	endif

	call cursor(ln, co)

	" set a dummy cursor position to adjust the start/end
	if t:DChar.dpv
		call s:ClearDiffCharPair()
		if [a:dir, a:pos] == [1, 0]				" forward/start : rightmost
			let t:DChar.clc[k][0 : 1] = [ln, col('$')]
		elseif [a:dir, a:pos] == [0, 1]			" backward/end : leftmost
			let t:DChar.clc[k][0 : 1] = [ln, 0]
		endif
	endif
endfunction

function! s:ShowDiffCharPair(key)
	if mode() != 'n' || !exists('t:DChar') | return | endif
	if s:GetDiffCharWID()[a:key] != s:GetWID() | return | endif

	let [ln, co] = [line('.'), col('.')]
	if co == col('$') | let co = 0 | endif

	let [lx, cx, bx] = t:DChar.clc[a:key]
	let t:DChar.clc[a:key] = [ln, co, b:changedtick]

	" if triggered by TextChanged, do nothing
	if b:changedtick != bx | return | endif

	if !empty(t:DChar.cpi)
		" pair highlight exists
		let [lp, cn] = t:DChar.cpi.P
		let cp = t:DChar.hlc[a:key][lp][cn][1]
		" inside the highlight, do nothing
		if ln == lp && cp[0] <= co && co <= cp[1] | return | endif
		call s:ClearDiffCharPair()	" outside, clear it
	endif

	if has_key(t:DChar.hlc[a:key], ln)
		let hc = filter(map(copy(t:DChar.hlc[a:key][ln]),
			\'[v:key, v:val[1]]'), 'v:val[1][0] <= co && co <= v:val[1][1]')
		if !empty(hc)
			" inside 1 valid diff unit or 2 contineous 'd'
			let ix = (len(hc) == 1) ? 0 : (ln == lx) ? co < cx : ln < lx
			call s:HighlightDiffCharPair(a:key, ln, hc[ix][0])
		endif
	endif
endfunction

function! s:HighlightDiffCharPair(key, line, col)
	let bkey = (a:key == 1) ? 2 : 1
	let bline = exists('t:DChar.dml') ?
				\t:DChar.dml[bkey][index(t:DChar.dml[a:key], a:line)] : a:line
	let aw = s:GetDiffCharWID()[a:key]
	let bw = s:GetDiffCharWID()[bkey]

	" set a pair cursor position (line, colnum) and match id
	let t:DChar.cpi.P = [a:line, a:col]
	let t:DChar.cpi.M = [bkey]

	" show a cursor-like highlight at the corresponding position
	let bc = t:DChar.hlc[bkey][bline][a:col][1]
	if bc != [0, 0]
		let [pos, len] = [bc[0], bc[1] - bc[0] + 1]
		call s:GotoWID(bw)
		let t:DChar.cpi.M +=
					\[s:MatchaddDiffCharPair(s:DCharHL.U, [bline, pos, len])]
		call s:GotoWID(aw)
	else
		let t:DChar.cpi.M += [-1]	" no cursor hl on empty line
	endif

	execute 'autocmd! diffchar WinLeave <buffer=' . winbufnr(aw) .
											\'> call s:ClearDiffCharPair()'

	if t:DChar.dpv != 2 | return | endif

	" echo the corresponding unit with its color
	let at = getbufline(winbufnr(aw), a:line)[0]
	let bt = getbufline(winbufnr(bw), bline)[0]
	let [ae, ac] = t:DChar.hlc[a:key][a:line][a:col]
	let gt = []
	if ae == 'c'
		let gt += [[t:DChar.hgp[
			\(count(map(t:DChar.hlc[a:key][a:line][: a:col], 'v:val[0]'),
				\'c') - 1) % len(t:DChar.hgp)], bt[bc[0] - 1 : bc[1] - 1]]]
	elseif ae == 'a'
		if 1 < ac[0]
			let gt += [[s:DCharHL.C, matchstr(at[: ac[0] - 2], '.$')]]
		endif
		let gt += [[s:DCharHL.D, repeat(s:VF.StrikeAttr ? ' ' :
			\&fillchars =~ 'diff' ? matchstr(&fillchars, 'diff:\zs.') : '-',
									\strwidth(at[ac[0] - 1 : ac[1] - 1]))]]
		if ac[1] < len(at)
			let gt += [[s:DCharHL.C, matchstr(at[ac[1] :], '^.')]]
		endif
	elseif ae == 'd'
		let ds = split(at[ac[0] - 1 : ac[1] - 1], '\zs')
		if 1 < bc[0]
			let gt += [[s:DCharHL.Z, ds[0]]]
		endif
		let gt += [[s:DCharHL.A, bt[bc[0] - 1 : bc[1] - 1]]]
		if bc[1] < len(bt)
			let gt += [[s:DCharHL.Z, ds[-1]]]
		endif
	endif
	execute join(map(gt, '"echohl " . v:val[0] . "|" .
			\"echon ''" . substitute(v:val[1], "''", "''''", "g") . "''"') +
													\['echohl None'], '|')
endfunction

function! s:ClearDiffCharPair()
	if !exists('t:DChar') | return | endif
	if !empty(t:DChar.cpi)
		let [wid, mid] = t:DChar.cpi.M
		if mid != -1
			let cwin = s:GetWID()
			call s:GotoWID(s:GetDiffCharWID()[wid])
			if index(map(getmatches(), 'v:val.id'), mid) != -1
				call matchdelete(mid)
			endif
			call s:GotoWID(cwin)
		endif
		execute 'autocmd! diffchar WinLeave <buffer=' .
						\winbufnr(s:GetDiffCharWID()[wid == 1 ? 2 : 1]) . '>'
		let t:DChar.cpi = {}
	endif
	if t:DChar.dpv == 2 | echon '' | endif
endfunction

function! diffchar#CopyDiffCharPair(dir)
	" a:dir : 0 = get, 1 = put
	if !exists('t:DChar') | return | endif

	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if s:GetDiffCharWID()[ak] == s:GetWID() | break | endif
	endfor
	let bk = (ak == 1) ? 2 : 1
	let aw = s:GetWID()
	let bw = s:GetDiffCharWID()[bk]

	let un = -1
	if t:DChar.dpv
		if !empty(t:DChar.cpi) | let [al, un] = t:DChar.cpi.P | endif
	else
		let [al, co] = [line('.'), col('.')]
		if co == col('$') | let co = 0 | endif
		if has_key(t:DChar.hlc[ak], al)
			let hc = filter(map(copy(t:DChar.hlc[ak][al]),
								\'[v:key, v:val[1]]'),
									\'v:val[1][0] <= co && co <= v:val[1][1]')
			if !empty(hc) | let un = hc[0][0] | endif
		endif
	endif
	if un == -1
		call s:EchoWarning('Cursor is not on a difference unit!')
		return
	endif

	let bl = exists('t:DChar.dml') ?
							\t:DChar.dml[bk][index(t:DChar.dml[ak], al)] : al
	let [ae, ac] = t:DChar.hlc[ak][al][un]
	let [be, bc] = t:DChar.hlc[bk][bl][un]
	let at = getbufline(winbufnr(aw), al)[0]
	let bt = getbufline(winbufnr(bw), bl)[0]

	let [x, y] = a:dir ? ['b', 'a'] : ['a', 'b']	" put : get
	let s1 = (1 < {x}c[0]) ? {x}t[: {x}c[0] - 2] : ''
	let s2 = ({x}e != 'a') ? {y}t[{y}c[0] - 1 : {y}c[1] - 1] : ''
	if {x}e == 'd' && {x}c != [0, 0]
		let ds = split({x}t[{x}c[0] - 1 : {x}c[1] - 1], '\zs')
		let s2 = (1 < {y}c[0] ? ds[0] : '') . s2 .
										\({y}c[1] < len({y}t) ? ds[-1] : '')
	endif
	let s3 = ({x}c[1] < len({x}t)) ? {x}t[{x}c[1] :] : ''
	let ss = s1 . s2 . s3

	if a:dir		" put
		call s:GotoWID(bw)
		noautocmd call setline(bl, ss)
		call s:UpdateDiffChar(bk)	" because TextChanged is not triggered
		call s:GotoWID(aw)
	else			" get
		call setline(al, ss)		" TextChanged is triggered
	endif
endfunction

function! diffchar#EchoDiffChar(lines, short)
	if !exists('t:DChar') | return | endif

	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if s:GetDiffCharWID()[ak] == s:GetWID() | break | endif
	endfor
	let bk = (ak == 1) ? 2 : 1

	let [sc, ru] = [&showcmd, &ruler]
	let [&showcmd, &ruler] = [0, 0]

	for al in a:lines
		let at = getbufline(winbufnr(s:GetDiffCharWID()[ak]), al)[0]
		if !has_key(t:DChar.hlc[ak], al)
			if !a:short | echo empty(at) ? "\n" : at | endif
			continue
		endif
		let bl = exists('t:DChar.dml') ?
						\t:DChar.dml[bk][index(t:DChar.dml[ak], al)] : al
		let bt = getbufline(winbufnr(s:GetDiffCharWID()[bk]), bl)[0]

		let hl = repeat('C', len(at))
		let tx = at
		for an in range(len(t:DChar.hlc[ak][al]) - 1, 0, -1)
			let [ae, ac] = t:DChar.hlc[ak][al][an]
			" enclose highlight and text in '[+' and '+]'
			" if strike not available
			if ae == 'c' || ae == 'a'
				let it = at[ac[0] - 1 : ac[1] - 1]
				if !s:VF.StrikeAttr | let it = '[+' . it . '+]' | endif
				let ih = repeat(ae == 'a' ? 'A' : 'T', len(it))
				let hl = (1 < ac[0] ? hl[: ac[0] - 2] : '') . ih . hl[ac[1] :]
				let tx = (1 < ac[0] ? tx[: ac[0] - 2] : '') . it . tx[ac[1] :]
			endif
			" enclose corresponding changed/deleted units in '[-' and '-]'
			" if strike not available, and insert them to highlight and text
			if ae == 'c' || ae == 'd'
				let bc = t:DChar.hlc[bk][bl][an][1]
				let it = bt[bc[0] - 1 : bc[1] - 1]
				if !s:VF.StrikeAttr | let it = '[-' . it . '-]' | endif
				let ih = repeat('D', len(it))
				if ae == 'c'
					let hl = (1 < ac[0] ? hl[: ac[0] - 2] : '') . ih .
															\hl[ac[0] - 1 :]
					let tx = (1 < ac[0] ? tx[: ac[0] - 2] : '') . it .
															\tx[ac[0] - 1 :]
				else
					if ac[0] == 1 && bc[0] == 1
						let hl = ih . hl
						let tx = it . tx
					else
						let ix = ac[0] +
									\len(matchstr(at[ac[0] - 1 :], '^.')) - 2
						let hl = hl[: ix] . ih . hl[ix + 1 :]
						let tx = tx[: ix] . it . tx[ix + 1 :]
					endif
				endif
			endif
		endfor

		let sm = a:short && &columns <= strdisplaywidth(tx)
		let ix = 0
		let tn = 0
		let gt = []
		for h in split(hl,'\%(\(.\)\1*\)\zs')
			if h[0] == 'T'
				let g = t:DChar.hgp[tn % len(t:DChar.hgp)]
				let tn += 1
			else
				let g = s:DCharHL[h[0]]
			endif
			let t = tx[ix : ix + len(h) - 1]
			if sm && h[0] == 'C'
				let s = split(t, '\zs')
				if ix == 0 &&
						\1 < len(s) && 3 < strdisplaywidth(join(s[: -2], ''))
					let t = '...' . s[-1]
				elseif ix + len(h) == len(tx) &&
						\1 < len(s) && 3 < strdisplaywidth(join(s[1 :], ''))
					let t = s[0] . '...'
				elseif 2 < len(s) && 3 < strdisplaywidth(join(s[1 : -2], ''))
					let t = s[0] . '...' . s[-1]
				endif
			endif
			let gt += [[g, t]]
			let ix += len(h)
		endfor
		execute join(['echo '''''] + map(gt, '"echohl " . v:val[0] . "|" .
			\"echon ''" . substitute(v:val[1], "''", "''''", "g") . "''"') +
													\['echohl None'], '|')
	endfor

	let [&showcmd, &ruler] = [sc, ru]
endfunction

function! diffchar#DiffCharExpr()
	if readfile(v:fname_in, '', 1) == ['line1'] &&
									\readfile(v:fname_new, '', 1) == ['line2']
		" return here for the 1st diff trial call
		call writefile(['1c1'], v:fname_out)
		return
	endif
	for fn in ['BuiltinFunctionExpr', 'DiffCommandExpr']
		let dfcmd = s:{fn}(v:fname_in, v:fname_new)
		if !empty(dfcmd) | break | endif
	endfor
	call writefile(dfcmd, v:fname_out)
endfunction

function! s:BuiltinFunctionExpr(f1, f2)
	let [f1, f2] = [readfile(a:f1), readfile(a:f2)]
	let save_igc = &ignorecase | let &ignorecase = (&diffopt =~ 'icase')
	if &diffopt =~ 'iwhite'
		for k in [1, 2]
			call map(f{k}, 'substitute(v:val, "\\s\\+", " ", "g")')
			call map(f{k}, 'substitute(v:val, "\\s\\+$", "", "")')
		endfor
	endif
	let ses = s:TraceDiffChar(f1, f2, [executable('diff') ?
							\get(t:, 'DiffSplitTime', g:DiffSplitTime) : 1/0])
	let &ignorecase = save_igc
	if ses == '*' | return [] | endif	" if timeout, return here with empty

	let dfcmd = []
	let [l1, l2] = [1, 1]
	for ed in split(ses, '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			let [l1, l2] += [qn, qn]
		else				" one or more '[+-]'
			let q1 = len(substitute(ed, '+', '', 'g'))
			let q2 = qn - q1
			let dfcmd += [(1 < q1 ? l1 . ',' : '') . (l1 + q1 - 1) .
								\(q1 == 0 ? 'a' : q2 == 0 ? 'd' : 'c') .
									\(1 < q2 ? l2 . ',' : '') . (l2 + q2 - 1)]
			let [l1, l2] += [q1, q2]
		endif
	endfor
	return dfcmd
endfunction

function! s:DiffCommandExpr(f1, f2)
	let opt = '-a --binary '
	if &diffopt =~ 'icase' | let opt .= '-i ' | endif
	if &diffopt =~ 'iwhite' | let opt .= '-b ' | endif
	let save_stmp = &shelltemp | let &shelltemp = 0
	let dout = system('diff ' . opt . a:f1 . ' ' . a:f2)
	let &shelltemp = save_stmp
	return filter(split(dout, '\n'), 'v:val[0] =~ "\\d"')
endfunction

function! diffchar#SetDiffModeSync()
	" DiffModeSync is triggered ON by FilterWritePost
	if !get(t:, 'DiffModeSync', g:DiffModeSync) | return | endif
	if !exists('s:dmbuf')
		" as a diff session, when FilterWritePos comes, current buf and
		" other 1 or more buf should be diff mode
		let s:dmbuf = map(filter(range(1, winnr('$')),
							\'getwinvar(v:val, "&diff")'), 'winbufnr(v:val)')
		if index(s:dmbuf, bufnr('%')) == -1 || min(s:dmbuf) == max(s:dmbuf)
			" not a diff session, then clear
			unlet s:dmbuf
			return
		endif
		" wait for the contineous 1 or more FilterWitePost (diff) or
		" 1 ShellFilterPost (non diff)
		autocmd! diffchar ShellFilterPost * call s:ClearDiffModeSync()
		" prepare to complete sync just in case for accidents
		if s:VF.Timers
			let s:id = timer_start(0, function('s:CompleteDiffModeSync'))
		else
			autocmd! diffchar CursorHold * call s:CompleteDiffModeSync(1)
			call s:ChangeUTOption(1, 1)
		endif
	endif
	" check if all the FilterWritePost has come
	if empty(filter(s:dmbuf, 'v:val != bufnr("%")'))
		call s:CompleteDiffModeSync(0)
	endif
endfunction

function! s:CompleteDiffModeSync(id)
	if exists('s:id')
		if a:id == 0 | call timer_stop(s:id) | endif
		unlet s:id
	else
		if exists('s:save_ch') && !empty(s:save_ch)
			execute 'autocmd! diffchar CursorHold * call ' . s:save_ch
			call s:ChangeUTOption(1)
		else
			execute 'autocmd! diffchar CursorHold *'
			call s:ChangeUTOption(0)
		endif
		silent call feedkeys("g\<Esc>", 'n')
	endif
	call s:ClearDiffModeSync()
	call s:PreSwitchDiffChar()
endfunction

function! s:ClearDiffModeSync()
	unlet s:dmbuf
	autocmd! diffchar ShellFilterPost *
endfunction

function! s:ResetDiffModeSync()
	" DiffModeSync is triggered OFF by OptionSet(diff) or CursorHold
	if exists('t:DChar') && exists('t:DChar.dml') && t:DChar.dms &&
		\!empty(filter(values(s:GetDiffCharWID()),
											\'!getwinvar(v:val, "&diff")'))
		" if either or both of DChar win is now non-diff mode,
		" reset it and show with current diff mode wins
		call eval(s:VF.DiffOptionSet ?
								\s:PreSwitchDiffChar() : s:SwitchDiffChar(-1))
	endif
endfunction

function! s:PreSwitchDiffChar()
	" set a timer or prepare to wait CursorHold on all buffers
	if s:VF.Timers
		call timer_start(0, function('s:SwitchDiffChar'))
	else
		autocmd! diffchar CursorHold * call s:SwitchDiffChar(0)
		call s:ChangeUTOption(1, 1)
	endif
endfunction

function! s:SwitchDiffChar(id)
	" a:id = 0 : via CursorHold on DiffModeSync (timer unavailable)
	"      > 0 : via timer on DiffModeSync (timer id)
	"     = -1 : usually switch DChar wins

	" clear CursorHold on all buffers if defined above
	if a:id == 0
		" reset or recover original command if exists
		if exists('s:save_ch') && !empty(s:save_ch)
			execute 'autocmd! diffchar CursorHold * call ' . s:save_ch
			call s:ChangeUTOption(1)
		else
			execute 'autocmd! diffchar CursorHold *'
			call s:ChangeUTOption(0)
		endif
	endif

	let cwin = s:GetWID()
	if exists('t:DChar')
		if index(values(s:GetDiffCharWID()), cwin) != -1
			call diffchar#ResetDiffChar()
		else
			" current win, not either of DChar wins, changes diff mode,
			" refresh Diff HL on all wins
			if s:VF.DiffHLUnhidden | call s:ToggleDiffHL(-1) | endif
		endif
	endif
	if !exists('t:DChar') && get(t:, 'DiffModeSync', g:DiffModeSync)
		let dwin = filter(range(winnr(), winnr('$')) + range(1, winnr() - 1),
												\'getwinvar(v:val, "&diff")')
		let dbuf = map(copy(dwin), 'winbufnr(v:val)')
		if min(dbuf) != max(dbuf)			" 2 or more diff mode wins exist
			execute 'noautocmd ' . dwin[0] . 'wincmd w'
			call diffchar#ShowDiffChar()
			call s:GotoWID(cwin)
		endif
	endif
endfunction

function! s:BufWinLeaveDiffChar(key)
	" when BufWinLeave comes via quit, close, hide, tabclose, tabonly
	" commands, find a tab page where the 'quit' buffer of the DChar window
	" exists, and then switch DChar on that tab page
	for tp in filter(range(tabpagenr('$'), 1, -1),
									\'!empty(s:Gettabvar(v:val, "DChar"))')
		let awin = map(filter(map(tabpagebuflist(tp),
			\'[s:VF.WindowID ? win_getid(v:key + 1, tp) : v:key + 1, v:val]'),
						\'v:val[1] == eval(expand("<abuf>"))'), 'v:val[0]')
		if !empty(awin)
			let ctab = tabpagenr()
			execute 'noautocmd ' . tp . 'tabnext'
			if t:DChar.dms
				call map(copy(awin), 'setwinvar(v:val, "&diff", 0)')
			endif
			let cwin = s:GetWID()
			let dwin = s:GetDiffCharWID()
			call s:GotoWID(dwin[index(awin, dwin[a:key]) != -1 ?
												\a:key : a:key == 1 ? 2 : 1])
			call s:SwitchDiffChar(-1)
			call s:GotoWID(cwin)
			call s:SweepInvalidDiffChar()
			execute 'noautocmd ' . ctab . 'tabnext'
		endif
	endfor
	call s:AdjustGlobalOption()
endfunction

function! s:QuitPreDiffChar(key)
	" when QuitPre comes, find all split windows where the 'quit' buffer
	" of the DChar window exists, and then switch DChar
	if !exists('t:DChar') | return | endif
	if 1 < len(filter(tabpagebuflist(), s:VF.QuitPreAbufFixed ?
				\'v:val == eval(expand("<abuf>"))' : 'v:val == bufnr("%") &&
							\v:val == winbufnr(s:GetDiffCharWID()[a:key])'))
		" try to check a 'quit' command and find a window to be quited
		let qwin = winnr()
		let qcmd = substitute(histget(':'), '\s\+\|q\%[uit].*$', '', 'g')
		if qcmd =~ '^[.$]$\|^\%([+-]\|\d\)\d*$'
			let d = matchstr(qcmd, '\d\+$')
			let n = empty(d) ? 1 : eval(d)
			let qwin =
				\(qcmd[0] == '+') ? qwin + n : (qcmd[0] == '-') ? qwin - n :
				\(qcmd[0] == '.') ? qwin : (qcmd[0] == '$') ? winnr('$') : n
			let qwin = (qwin < 1) ? 1 : (winnr('$') < qwin) ?
															\winnr('$') : qwin
		endif
		if s:VF.WindowID | let qwin = win_getid(qwin) | endif
		if qwin == s:GetDiffCharWID()[a:key]
			" the quit window is actually a target DChar window
			let cwin = s:GetWID()
			call s:GotoWID(qwin)
			if t:DChar.dms | noautocmd let &diff = 0 | endif
			call s:SwitchDiffChar(-1)
			call s:GotoWID(cwin)
		endif
	endif
	call s:SweepInvalidDiffChar()
endfunction

function! s:SweepInvalidDiffChar()
	" close and hide commands on a split window does not trigger an event,
	" see WinEnter to check if both or either of DChar win was disappeared
	if exists('t:DChar')
		let lw = filter(values(s:GetDiffCharWID()),
					\s:VF.WindowID ? 'win_id2win(v:val) != 0' : 'v:val != 0')
		if len(lw) == 1
			" either of DChar wins has gone, sweep remaining win and set again
			let cwin = s:GetWID()
			call s:GotoWID(lw[0])
			call s:SwitchDiffChar(-1)
			call s:GotoWID(cwin)
		elseif len(lw) == 0
			" both of DChar wins have gone, clear event, HL and DChar
			call s:ToggleDiffCharEvent(0)
			if s:VF.DiffHLUnhidden | call s:ToggleDiffHL(0) | endif
			call s:SetDiffCharWID({})
			unlet t:DChar
		endif
	endif
	" find all buffer belonging to valid DChar in all tab page
	let db = []
	for tp in filter(range(1, tabpagenr('$')),
									\'!empty(s:Gettabvar(v:val, "DChar"))')
		let db += map(filter(map(tabpagebuflist(tp),
			\'[s:VF.WindowID ? win_getid(v:key + 1, tp) : v:key + 1, v:val]'),
					\'index(values(s:GetDiffCharWID(tp)), v:val[0]) != -1'),
																\'v:val[1]')
	endfor
	if empty(db)
		" sweep all event and initialize because no valid DChar exists
		autocmd! diffchar
		autocmd! diffchar FilterWritePost * call diffchar#SetDiffModeSync()
		autocmd! diffchar ColorScheme * call s:DefineDiffCharHL()
	else
		" sweep remaining buffer specific event not belonging to any DChar
		for bn in filter(range(1, bufnr('$')), 'index(db, v:val) == -1')
			execute 'autocmd! diffchar * <buffer=' . bn . '>'
		endfor
	endif
endfunction

function! s:EchoWarning(msg)
	echohl WarningMsg | echo a:msg | echohl None
endfunction

if s:VF.WindowID
let s:GetWID = function('win_getid')

function! s:GotoWID(wid)
	noautocmd call win_gotoid(a:wid)
endfunction

function! s:SetDiffCharWID(wid)
	let t:DChar.wid = map(copy(a:wid), 'win_getid(v:val)')
endfunction

function! s:GetDiffCharWID(...)
	return a:0 ? s:Gettabvar(a:1, 'DChar').wid : t:DChar.wid
endfunction

else

let s:GetWID = function('winnr')

function! s:GotoWID(wid)
	execute 'noautocmd ' . a:wid . 'wincmd w'
endfunction

function! s:SetDiffCharWID(wid)
	for wvr in map(range(1, winnr('$')), 'getwinvar(v:val, "")')
		if has_key(wvr, 'DCharWID') | unlet wvr.DCharWID | endif
	endfor
	call map(copy(a:wid), 'setwinvar(v:val, "DCharWID", eval(v:key))')
endfunction

function! s:GetDiffCharWID(...)
	let tp = a:0 ? a:1 : tabpagenr()
	let wid = map(range(1, tabpagewinnr(tp, '$')),
									\'gettabwinvar(tp, v:val, "DCharWID")')
	return map({'1': 0, '2': 0}, 'index(wid, eval(v:key)) + 1')
endfunction
endif

if s:VF.MatchaddPos
function! s:MatchaddDiffChar(key, lhc)
	for [l, hc] in items(a:lhc)
		let l = eval(l)
		let t:DChar.mid[a:key][l] = [matchaddpos(s:DCharHL.C, [[l]], -3)]
		for [h, c] in items(hc)
			call map(c, '[l, v:val[0], v:val[1] - v:val[0] + 1]')
			let t:DChar.mid[a:key][l] += map(range(0, len(c) - 1, 8),
								\'matchaddpos(h, c[v:val : v:val + 7], -2)')
		endfor
	endfor
endfunction

function! s:MatchaddDiffCharPair(hl, lpn)
	return matchaddpos(a:hl, [a:lpn], -1)
endfunction

else

function! s:MatchaddDiffChar(key, lhc)
	for [l, hc] in items(a:lhc)
		let l = eval(l)
		let dl = '\%' . l . 'l'
		let t:DChar.mid[a:key][l] = [matchadd(s:DCharHL.C, dl . '.', -3)]
		for [h, c] in items(hc)
			call map(c, '"\\%>" . (v:val[0] - 1) . "c\\%<" .
													\(v:val[1] + 1) . "c"')
			let dc = (1 < len(c)) ? '\%(' . join(c, '\|') . '\)' : c[0]
			let t:DChar.mid[a:key][l] += [matchadd(h, dl . dc, -2)]
		endfor
	endfor
endfunction

function! s:MatchaddDiffCharPair(hl, lpn)
	return matchadd(a:hl, '\%' . a:lpn[0] . 'l\%>' . (a:lpn[1] - 1) . 'c\%<' .
											\(a:lpn[1] + a:lpn[2]) . 'c', -1)
endfunction
endif

if s:VF.GettabvarFixed
let s:Gettabvar = function('gettabvar')

else

function! s:Gettabvar(tp, var)
	call gettabvar(a:tp, a:var)				" a dummy call as a workaround
	return gettabvar(a:tp, a:var)
endfunction
endif

function! s:AdjustGlobalOption()
	if !s:VF.DiffOptionSet
		call s:ChangeUTOption(exists('t:DChar.dml') && t:DChar.dms)
	endif
	if s:VF.DiffHLUnhidden
		call s:ChangeDiffCTHL(exists('t:DChar.ovd'))
	endif
endfunction

if !s:VF.Timers || !s:VF.DiffOptionSet
function! s:ChangeUTOption(on, ...)
	if a:on
		if !exists('s:save_ut') | let s:save_ut = &updatetime | endif
		let &updatetime = a:0 ? a:1 : 500		" decrease anyway
	elseif exists('s:save_ut')
		let &updatetime = s:save_ut | unlet s:save_ut
	endif
endfunction
endif

if s:VF.DiffHLUnhidden
function! s:ChangeDiffCTHL(on)
	for hl in ['c', 't']
		execute 'silent highlight clear ' . s:DCharHL[hl]
		execute 'silent highlight ' . s:DCharHL[hl] . ' ' .
														\s:DiffCTHL[hl][a:on]
	endfor
endfunction

function! s:ToggleDiffHL(on)
	if exists('t:DChar.dml')
		if a:on == -1
			call s:RestoreDiffHL() | call s:OverdrawDiffHL()
		else
			call eval(a:on ? 's:OverdrawDiffHL()' : 's:RestoreDiffHL()')
			call s:ChangeDiffCTHL(a:on)
		endif
	endif
endfunction

function! s:OverdrawDiffHL()
	" overdraw DiffChange/DiffText area with its match
	if exists('t:DChar.ovd') | return | endif
	let t:DChar.ovd = 1
	let [dc, dt] = [hlID(s:DCharHL.c), hlID(s:DCharHL.t)]
	if has('nvim') && s:IsDiffHLIDCorrect() == 0
		let [dc, dt] -= [1, 1]
	endif
	let cwin = s:GetWID()
	for w in filter(range(1, winnr('$')), 'getwinvar(v:val, "&diff")')
		execute 'noautocmd ' . w . 'wincmd w'
		let cl = filter(range(1, line('$')),
								\'index([dc, dt], diff_hlID(v:val, 1)) != -1')
		let tl = []
		for l in cl
			let t = filter(range(1, col([l, '$']) - 1),
												\'diff_hlID(l, v:val) == dt')
			if !empty(t) | let tl += [[l, t[0], len(t)]] | endif
		endfor
		for [hl, ll, pr] in [['C', cl, -5], ['T', tl, -4]]
			if !empty(ll)
				if !has_key(w:, 'DCharDTM') | let w:DCharDTM = [] | endif
				let w:DCharDTM += map(range(0, len(ll) - 1, 8),
					\'matchaddpos(s:DCharHL[hl], ll[v:val : v:val + 7], pr)')
			endif
		endfor
	endfor
	call s:GotoWID(cwin)
endfunction

function! s:RestoreDiffHL()
	" delete all the overdrawn DiffChange/DiffText match ids
	if !exists('t:DChar.ovd') | return | endif
	let cwin = s:GetWID()
	for w in filter(range(1, winnr('$')),
									\'!empty(getwinvar(v:val, "DCharDTM"))')
		execute 'noautocmd ' . w . 'wincmd w'
		let mx = map(getmatches(), 'v:val.id')
		call map(filter(w:DCharDTM, 'index(mx, v:val) != -1'),
														\'matchdelete(v:val)')
		unlet w:DCharDTM
	endfor
	call s:GotoWID(cwin)
	unlet t:DChar.ovd
endfunction
endif

" set highlight groups used for diffchar
let s:DCharHL = {'A': 'DiffAdd', 'c': 'DiffChange', 't': 'DiffText',
				\'C': 'dcDiffChange', 'T': 'dcDiffText', 'Z': 'dcDiffAddPos',
								\'U': s:VF.GUIColors ? 'Cursor' : 'VertSplit'}
let s:DCharHL = extend(s:DCharHL, s:VF.StrikeAttr ?
			\{'d': 'DiffDelete', 'D': 'dcDiffDelStr'} : {'D': 'DiffDelete'})
let s:DiffCTHL = {}

function! s:DefineDiffCharHL()
	" dcDiffAddPos = DiffChange + bold and underline
	" dcDiffDelStr = DiffDelete + strikethrough
	" dcDiffChange = DiffChange
	" dcDiffText = DiffText
	for [fh, th, at] in [['c', 'Z', ['bold', 'underline']],
											\['c', 'C', []], ['t', 'T', []]] +
					\(s:VF.StrikeAttr ? [['d', 'D', ['strikethrough']]] : [])
		let hd = hlID(s:DCharHL[fh])
		let ha = []
		for hm in ['term', 'cterm', 'gui']
			if hm != 'term'
				let ha += map(['fg', 'bg', 'sp'],
							\'hm . v:val . "=" . synIDattr(hd, v:val, hm)')
			endif
			let ha += [hm . '=' . join(filter(['bold', 'italic', 'reverse',
							\'inverse', 'standout', 'underline', 'undercurl',
					\'strikethrough'], 'synIDattr(hd, v:val, hm)') + at, ',')]
		endfor
		let hx = join(filter(ha, 'v:val !~ "=\\(-1\\)\\=$"'))
		execute 'silent highlight clear ' . s:DCharHL[th]
		execute 'silent highlight ' . s:DCharHL[th] . ' ' . hx
		" set a dictionary for changing vim original DiffChange/DiffText
		if th == 'C'				" 1: leave bg only
			let s:DiffCTHL[fh] = {0: hx,
									\1: join(filter(ha, 'v:val =~ "bg="'))}
		elseif th == 'T'			" 1: leave noting
			let s:DiffCTHL[fh] = {0: hx, 1: ''}
		endif
	endfor
	if s:VF.DiffHLUnhidden
		call s:ChangeDiffCTHL(exists('t:DChar.ovd'))
	endif
endfunction

autocmd! diffchar ColorScheme * call s:DefineDiffCharHL()
doautocmd diffchar ColorScheme

if has('nvim')
function! s:IsDiffHLIDCorrect()
	" in nvim 2.1, id returned by diff_hlID() = correct id - 1.
	" this function checks if diff_hlID() still has problem or not.
	if exists('s:HLIDchecked') | return s:HLIDchecked | endif
	let [da, dc, dt] =
					\[hlID(s:DCharHL.A), hlID(s:DCharHL.c), hlID(s:DCharHL.t)]
	let cwin = s:GetWID()
	let ok = -1
	let k = 1
	while k <= 2 && ok < 0
		call s:GotoWID(s:GetDiffCharWID()[k])
		let l = 1
		while l <= line('$') && ok < 0
			let id = diff_hlID(l, 1)
			if id == 0			" no HLID, then can not check
			elseif id == dc || id == dt
				let ok = 1		" C/T, then correct
			elseif id == da
				" A in part of columns, then incorrect
				" A in all columns, then A/C uncertain
				let ok = !empty(filter(range(1, col([l, '$'])),
									\'diff_hlID(l, v:val) != id')) ? 0 : -2
			else
				let ok = 0		" other than A/C/T, then incorrect
			endif
			let l += 1
		endwhile
		let k += 1
	endwhile
	call s:GotoWID(cwin)
	if ok == -2
		let ok = 1				" still A/C uncertain means C, then correct
	endif
	if ok != -1 | let s:HLIDchecked = ok | endif
	return ok
endfunction
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
