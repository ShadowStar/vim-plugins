
au BufNewFile,BufRead *.asm,*.[sS]	call s:det_asm()

function! s:det_asm()
	let n = 1
	while n < 10 && n < line("$")
		let line = getline(n)
		if line =~ '.* file format .*mips'
			set syntax=asm_mips
			return
		endif
		if line =~ '.* file format .*x86-64' || line =~ '.* file format .*i[36]86'
			set syntax=asm_x86
			return
		endif
		let n = n + 1
	endwhile
endfunction

