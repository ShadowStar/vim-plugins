function! base64#strip(value)
	return substitute(a:value, '\n$', '', 'g')
endfunction

function! base64#encode(input)
	if has("unix")
		let s:os = system("uname")
		if s:os == "Darwin\n"
			return base64#strip(system('base64', a:input))
		else
			return base64#strip(system('base64 --wrap=0', a:input))
		endif
	elseif has("win32")
		return base64#strip(system('python -m base64', a:input))
	else
		echoerr "Unknown OS"
	endif
endfunction

function! base64#decode(input)
	if has("unix")
		let s:os = system("uname")
		if s:os == "Darwin\n"
			return base64#strip(system('base64 --decode', a:input))
		else
			return base64#strip(system('base64 --decode --wrap=0 --ignore-garbage', a:input))
		endif
	elseif has("win32")
		return base64#strip(system('python -m base64 -d', a:input))
	else
		echoerr "Unknown OS"
	endif
endfunction

