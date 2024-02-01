" autoload/hexx.vim
"
" HexX - Richard Bentley-Green, 10/01/2024
"
" Hex editing of binary files
"
if exists('g:Hexx_loaded_autoload')
  finish
endif
let g:Hexx_loaded_autoload = 1

" ----------------------------------
" Options

" The external 'xxd' program to use
const s:XXD = get(g:, 'Hexx_xxdExe', 'xxd')

" Option to switch off line wrap when HexX is active
const s:removeLineWrap = get(g:, 'Hexx_removeLineWrap', 1)

" Options for hex formatting; number of bytes per line and grouping (1, 2, or 4, etc)
const s:bytes_per_line = get(g:, 'Hexx_bytesPerLine', 16)
const s:byte_grouping = get(g:, 'Hexx_byteGrouping', 1)

" Use upper ('u') or lower ('l') case hex characters for display
const s:hex_case = get(g:, 'Hexx_hexCase', 'l')

" Note: g:Hexx_newByteValue is set by s:initialise()

" Character to use for ASCII representation that is unprintable (eg, a control character)
const s:unprintable = '.'

" Option to stop 'x' operation from overwriting yank buffer (0 = vim default, which is
" to overwrite the yank buffer)
const s:x_noyank = get(g:, 'Hexx_xDoesNotYank', 1)

" If enabled (set to 1), then any 'carriage return' (ASCII 0x0d) characters
" entered via the 'C' operation are converted to 'newline' (ASCII 0x0a)
" characters. The 'carriage return' character is usually generated when the
" 'return' key is hit
const s:convertNewline = get(g:, 'Hexx_convertNewline', 1)

" If enabled (set to 1) then `<esc>` (ASCII 0x1b) entered via the 'C' operation
" will not be interpreted as a character to edit the bufferi with, but as an
" indication to exit the 'C' operation (ie - '<esc>' will work like it does for
" other operations such as 'r')
const s:exitWithEsc = get(g:, 'Hexx_exitWithEsc', 1)

" UTF encoding scheme - 8, 16 or 32, and UTF-16/32 endian - 'b' or 'l'
let s:utfEncoding = get(g:, 'Hexx_utfEncoding', 8)
let s:utfEndian = get(g:, 'Hexx_utfEndian', 'b')

" Allow yank & paste operations
" See README for full details
const s:allowYankAndPaste = get(g:, 'Hexx_allowYankAndPaste', 0)

" Option to print edit mode status change to command line
const s:printEditModeChange = get(g:, 'Hexx_printEditModeChange', 1)

" Column number of first and last character displayed. These constants are dicatated by xxd
const s:col_first = 11
const s:col_per_group = (s:byte_grouping * 2) + 1
const s:groups_per_line = s:bytes_per_line / s:byte_grouping
const s:col_last = s:col_first + (s:col_per_group * s:groups_per_line) - 1
const s:asciiStartCol = s:col_first + (s:groups_per_line * s:col_per_group) + 1

" These two constants are used by the syntax highlighting and by s:byteToLC()
const hexx#AsciiStartCol = s:asciiStartCol
const hexx#AsciiEndCol = hexx#AsciiStartCol + s:bytes_per_line

" Hex tables
const s:hexL = '0123456789abcdef'
const s:hexH = '0123456789ABCDEF'

" HexX filetype
const s:hexxFiletype = 'hexx'

" Note: Cursor highlight groups are set by s:initialise()

" Indication of whether or not to leave cursor highlight in-place when
" dropping into suspended mode. 1 = display cursor in suspend mode, 0 = do not
const s:suspendCursor = get(g:, 'Hexx_suspendCursor', 0)

" A maximum count to allow for the operations 'r', 'R', 'S', 'i', 'A', 'x'. This is a
" safety measure to prevent accidentally adding or deleting massive amounts of
" data to/from the buffer. A value of 0 (zero) will disable this check
const s:countLimit = get(g:, 'Hexx_countLimit', 256)

" Some constants indicating the Hexx 'mode' (b:HexxMode)
" 'none'    - No mode set (Hexx not active - buffer should be in its original text/binary mode)
" 'enabled' - Hexx mode enabled and active editing allowed
" 'suspend' - Buffer in Hexx mode but not being actively edited
"
const s:modeNone = 0
const s:modeEnabled = 1
const s:modeSuspended = 2

" Some constants indicating the Hexx 'edit mode' (b:HexxEditMode)
" 'op'   - Only operation/cursor entry and 'count' accepted
" 'icmd' - Only a repeat of the last operation (which will be 'A' or 'i') or nibble/byte data
"          entry accepted (modifying buffer)
" 'data' - Only byte data entry accepted (modifying buffer)
" 'undef' - 'Undefined' - Used for initialisation. Never conveyed to user

const s:editModeOp = 0
const s:editModeIcmd = 1
const s:editModeData = 2
const s:editModeUndef = 9

" ----------------------------------
" Key mappings

" A number of 'internal' key mappings are defined. This is the prefix to use for them
const s:leaderBase = get(g:, 'Hexx_leaderBase', '<leader>7')

" A 'resolved' version of 's:leaderBase'.
" This is needed in case 's:leaderBase' contains a '<leader>' character; I am
" not aware of a built-in way of resolving this to the single character it represents
" (escape strings do not work on "<leader>")
const s:leaderBaseRes = substitute(s:leaderBase, '<leader>', (get(g:, 'mapleader', '') != '') ? g:mapleader : '\', 'g')

" 'Suspend edit' key
const s:suspendEditKey = get(g:, 'Hexx_suspendEdit', 's')

" 'Exit edit' key
const s:exitEditKey = get(g:, 'Hexx_exitEdit', "\<esc>")

" A dummy 'visual yank to blackhole register' operation. This is inserted by
" some of the key mappings to force returning focus to the window after outputting
" text to the command line (this operation was chosen because it doesn't modify the
" buffer and is reliable. It DOES alter the visual selection area of course, but
" that doesn't matter here
const s:nullCmd = 'v"_y'

" To avoid writing the buffer or exiting HexX accidentally (which can be really annoying),
" request confirmation first. This controls the confirmation
let s:secondWarn = ''

" Character used in data entry key mapping. There should be no reason to
" alter this (be very careful if you do!)
const s:entryChar = '#'

" A newline character
const s:newlineVal = 0x0a
const s:newlineChar = nr2char(0x0a)

" ----------------------------------
" This is a non-standard colour
highlight default link StatusMsg Normal

" Print a 'status' message to the command line
function s:PrintStatusMsg(msg)
  echohl StatusMsg | echo a:msg | echohl None
endfunction

" Print a 'warning' message to the command line
function s:PrintWarningMsg(msg)
  echohl WarningMsg | echo a:msg | echohl None
endfunction

" ----------------------------------
" Set edit mode and (optionally) print the new mode now in affect
"
" mode - New mode to set
"
function s:setEditMode(mode)
  if s:printEditModeChange && (a:mode != b:HexxEditMode)
    echohl ModeMsg | echo ((a:mode) ? ((a:mode == s:editModeIcmd) ? '-- CMD/MODIFY --' : '-- MODIFY --') : '-- CMD --') | echohl None
  endif

  let b:HexxEditMode = a:mode
endfunction

" ----------------------------------
" Convert byte number to column/row on display (Hex format)
"
" byte - Byte offset within buffer (zero-based). This MUST be smaller
"        than the length of the buffer
" nibble - Nibble offset within byte. If this is 0 (ms) or 1 (ls)
"          then the cursor position is calculated for the 'Hex' part of
"          thw display. If this is < 0 then the cursor position is
"          calculated for the 'ASCII' part of the display
"
" Returns a list (array) in the format [line, column]
"
function s:byteToLC(byte, nibble)
  " Position cursor
  let l:numBytes = b:HexxNumBytes

  " The line number (base 1) and logical byte offset (base 0) within the line
  let l:line = (a:byte + s:bytes_per_line) / s:bytes_per_line
  let l:byteInLine = a:byte - ((l:line - 1) * s:bytes_per_line)

  if a:nibble >= 0
    " 'Hex' part of display

    " The group (base 0), and col number (base 1)
    let l:group = l:byteInLine / s:byte_grouping
    let l:nibble = ((l:byteInLine - (l:group * s:byte_grouping)) * 2) + a:nibble
    let l:col = s:col_first + (l:group * s:col_per_group) + l:nibble
  else
    " 'ASCII' part of display

    " The col number (base 1)
    let l:col = s:asciiStartCol + l:byteInLine
  endif

  return [l:line, l:col]
endfunction

" ----------------------------------
" Un-highlight Hex cursor byte
"
function s:unhighlightHexCursor()
  if exists('b:HexxMatchCursor')
    call matchdelete(b:HexxMatchCursor)
    unlet b:HexxMatchCursor

    if exists('b:HexxMatchNibble')
      call matchdelete(b:HexxMatchNibble)
      unlet b:HexxMatchNibble
    endif
  endif
endfunction

" ----------------------------------
" Highlight the cursor byte in the Hex data in Hex mode
"
" cursor - Pre-calculated position in Hex data to highlight
"
function s:highlightHexCursor(cursor)
  call s:unhighlightHexCursor()
  if s:hlHexnibble ==# ''
    let b:HexxMatchCursor = matchaddpos(s:hlHexcursor, [[a:cursor[0], a:cursor[1], 2]])
  else
    let b:HexxMatchCursor = matchaddpos(s:hlHexcursor, [[a:cursor[0], a:cursor[1] + (1 - b:HexxCursorNibble), 1]])
    let b:HexxMatchNibble = matchaddpos(s:hlHexnibble, [[a:cursor[0], a:cursor[1] + b:HexxCursorNibble, 1]])
  endif
endfunction

" ----------------------------------
" Un-highlight ASCII cursor byte
"
function s:unhighlightASCIICursor()
  if exists('b:HexxMatchASCIICursor')
    call matchdelete(b:HexxMatchASCIICursor)
    unlet b:HexxMatchASCIICursor
  endif
endfunction

" ----------------------------------
" Highlight the cursor in the ASCII data in Hex mode
"
" byte - The byte in the buffer to set the cursor at
"
function s:highlightASCIICursor(byte)
  " Determine the character position in the buffer
  let l:start = s:byteToLC(a:byte, -1)

  call s:unhighlightASCIICursor()
  let b:HexxMatchASCIICursor = matchaddpos(s:hlASCIIcursor, [l:start])
endfunction

" ----------------------------------
" Position cursor (Hex format) and highlight its position
"
" byte - Byte offset (zero-based)
" nibble - Nibble offset within byte. If this is 0 (ms) or 1 (ls)
"          then the cursor is placed in the 'Hex' part of the display.
"          If this is < 0 then the cursor is placed in the 'ASCII' part
"          of the display
"
function s:posnCursor(byte, nibble)
  let l:posn = s:byteToLC(a:byte, a:nibble)
  call cursor(l:posn[0], l:posn[1])

  " Highlight cursor position etc
  if a:nibble >= 0
    if a:nibble
      let l:posn[1] -= 1
    endif
    call s:highlightHexCursor(l:posn)
    call s:highlightASCIICursor(a:byte)
  endif
endfunction

" ----------------------------------
" Convert buffer from binary to hex format
"
" This converts the current buffer to a hex editable format
"
function s:convertToHex()
  if b:HexxNumBytes
    " Convert to hex
    silent exe '%!'.s:XXD.' -c '.s:bytes_per_line.' -g '.s:byte_grouping.((s:hex_case ==# 'u') ? ' -u' : '')
  else
    " Buffer is empty
    silent exe "normal! i00000000:  \<esc>"
  endif

  " Vim can leave remnents of the binary data on screen - tidy up
  mode

  " Re-instate original position of buffer in window
  let l:topLine = get(b:, 'HexxTopLine', 1) + &scrolloff
  if l:topLine > line('w$')
    let l:topLine = line('w$')
  endif

  call cursor(l:topLine, 1)
  exe "normal! zt"
endfunction

" ----------------------------------
" Convert buffer from hex to binary format
"
" This converts the current buffer to a binary format
"
function s:convertToBin()
  " Determine if last character in buffer is a newline character
  let l:eolBuff = (b:HexxNumBytes && (s:getByteValAtOffset(b:HexxNumBytes - 1) ==# s:newlineVal))

  " Stop Vim messing with any newline (or not) at end of buffer
  let &l:endofline = l:eolBuff

  if b:HexxNumBytes
    " Remember position of buffer in window
    let b:HexxTopLine = line('w0')

    " Convert to binary
    silent exe '%!'.s:XXD.' -r -c '.s:bytes_per_line.' -g '.s:byte_grouping.((s:hex_case ==# 'u') ? ' -u' : '')
  else
    " Buffer is empty
    %delete _
  endif
endfunction

" ----------------------------------
" Check validity of a single ASCII Hex character (1 nibble) and if ok,
" return it, converted to the configured case if necessary
"
" char - The single lower-case ASCII Hex character / nibble to interpret
"
" Returns single ASCII Hex character converted to configured case
" ('' is returned if 'char' is not a valid hex character)
"
function s:hexCharToChar(char)
  let l:char = ''

  let l:charn = char2nr(a:char)
  if (l:charn >= 0x30) && (l:charn <= 0x39)
    let l:char = a:char
  elseif (l:charn >= 0x61) && (l:charn <= 0x66)
    let l:char = (s:hex_case == 'l') ? a:char : nr2char(l:charn - 0x20)
  endif

  return l:char
endfunction

" ----------------------------------
" Convert a single ASCII character to a 2 character (1 byte) hex string
"
" char - Character to convert
"
" Returns 2 character (1 byte) hex string
"
function s:charToHex(char)
  let l:charn = char2nr(a:char)
  return ((s:hex_case == 'l') ? (s:hexL[and(l:charn / 16, 0x0f)].s:hexL[and(l:charn, 0x0f)]) : (s:hexU[and(l:charn / 16, 0x0f)].s:hexU[and(l:charn, 0x0f)]))
endfunction

" ----------------------------------
" Convert a 2 character (1 byte) hex string to a single printable ASCII character
"
" string - Hex string to convert
"
" Returns single ASCII character (or s:unprintable if unprintable)
"
function s:hexToChar(hex)
  let l:charn = (s:nibbleToInt(a:hex[0]) * 16) + s:nibbleToInt(a:hex[1])
  return ((l:charn >= 0x20) && (l:charn <= 0x7e)) ? nr2char(l:charn) : s:unprintable
endfunction

" ----------------------------------
" Convert a numeric 8 bit value into a single printable ASCII character
"
" num - The numeric value to convert
"
" Returns single ASCII character (or s:unprintable if unprintable)
"
function s:numToChar(num)
  return ((a:num >= 0x20) && (a:num <= 0x7e)) ? nr2char(a:num) : s:unprintable
endfunction

" ----------------------------------
" Convert a single character (1 nibble) hex character to a numberic value
"
" char - The single ASCII Hex character / nibble to interpret
"
" Returns single integer in the range 0 to 15
"
function s:nibbleToInt(char)
  let l:val = 0
  let l:charn = char2nr(a:char)

  if (l:charn >= 0x30) && (l:charn <= 0x39)
    let l:val = l:charn - 0x30
  elseif (l:charn >= 0x41) && (l:charn <= 0x46)
    let l:val = l:charn - 0x37
  else " (l:charn >= 0x61) && (l:charn <= 0x66)
    let l:val = l:charn - 0x57
  endif

  return l:val
endfunction

" ----------------------------------
" Return the character at the cursor position (Text/binary format)
" If the cursor is in virtual space then it shall return the last character
" on the line. If the line is blank then it shall return ''
"
" offset - Signed column offset (0 = exact cursor position)
"
function s:getCharAtCursor(offset)
  " Apparently faster than the 'matchstr' method
  return strcharpart(strpart(getline('.'), col('.') - 1 + a:offset), 0, 1)
endfunction

" ----------------------------------
" Return byte at the cursor position (Hex format), regardless of curent nibble
"
" Returns byte as a numeric value
"
function s:getByteValAtCursor()
  return ((s:nibbleToInt(s:getCharAtCursor(-b:HexxCursorNibble)) * 16) + s:nibbleToInt(s:getCharAtCursor(1 - b:HexxCursorNibble)))
endfunction

" Return byte in buffer at specified byte location (Hex format)
"
" byte - Absolute byte offset within buffer (zero-based). This MUST
"        be smaller than the length of the buffer
"
" Returns byte as a numeric value
"
function s:getByteValAtOffset(byte)
  let l:posn = s:byteToLC(a:byte, 0)
  call cursor(l:posn[0], l:posn[1])
  let l:charVal = (s:nibbleToInt(s:getCharAtCursor(0)) * 16) + s:nibbleToInt(s:getCharAtCursor(1))

  " Put cursor back where it was
  let l:posn = s:byteToLC(b:HexxCursor, b:HexxCursorNibble)
  call cursor(l:posn[0], l:posn[1])

  return l:charVal
endfunction

" ----------------------------------
" Update single ASCII character to reflect the Hex data at the cursor position.
"
" NOTE: This leaves the cursor in the ASCII part of the display
"
" a:1 - Optional. If specified, this is the numeric 8 bit character value. If
"       not specified, the character value is extracted from the hex
"       representation at the cursor position
"
function s:updateASCIIChar(...)
  let l:char = (a:0) ? s:numToChar(a:1) : s:hexToChar(s:getCharAtCursor(-b:HexxCursorNibble).s:getCharAtCursor(1 - b:HexxCursorNibble))
  call s:posnCursor(b:HexxCursor, -1)
  exe 'normal! r'.l:char."\<esc>"
endfunction

" ----------------------------------
" Split a single character up into (possibly) multi-byte numeric UTF representation
"
" NOTE: There are a number of ranges in the UTF specification that are illegal
"       or are undefined/reserved. This function only handles (by disallowing)
"       one of the possible cases; that of accidentally creating a UTF-16 orphan
"       surrogate
"
" format - Either 8, 16 or 32 to indicate UTF format required
" codepoint - The UTF code point to convert (numeric). This is expected to be
"             in the range 0 to 0x10ffff
" endian - Endian - 'b' = big (default) or 'l' (little). This only applies to
"          UTF-16 and UTF-32
"
" Returns a list (array) with one numeric byte per element. Together, the
" elements form the UTF representation requested
" On an error (ie, the codepoint is illegal) an empty array is returned
"
function s:splitUTF(format, codepoint, endian)
  let l:utfBytes = []

  if (a:codepoint >= 0) && (a:codepoint <= 0x10ffff)
    if a:format == 8
      " UTF-8
      if a:codepoint <= 0x7f
        let l:utfBytes = [a:codepoint]
      elseif a:codepoint <= 0x7ff
        let l:utfBytes = [or(0xc0, a:codepoint / 64), or(0x80, and(a:codepoint, 0x3f))]
      elseif a:codepoint <= 0xffff
        let l:utfBytes = [or(0xe0, a:codepoint / 4096), or(0x80, and(a:codepoint / 64, 0x3f)), or(0x80, and(a:codepoint, 0x3f))]
      else
        " 0x10000 to 0x10ffff
        let l:utfBytes = [or(0xf0, and(a:codepoint / 262144, 0x0f)), or(0x80, and(a:codepoint / 4096, 0x3f)), or(0x80, and(a:codepoint / 64, 0x3f)), or(0x80, and(a:codepoint, 0x3f))]
      endif
    elseif a:format == 16
      " UTF-16
      if a:codepoint <= 0xffff
        if (a:codepoint < 0xd800) || (a:codepoint > 0xdfff)
          let l:utfBytes = (a:endian ==# 'b') ? [a:codepoint / 256, and(a:codepoint, 0x0ff)] : [and(a:codepoint, 0x0ff), a:codepoint / 256]
        endif
      else
        " 0x10000 to 0x10ffff
        let l:cp = a:codepoint - 0x10000
        let l:w1 = or(0xd800, l:cp / 1024)
        let l:w2 = or(0xdc00, and(l:cp, 0x3ff))
        let l:utfBytes = (a:endian ==# 'b') ? [l:w1 / 256, and(l:w1, 0x0ff), l:w2 / 256, and(l:w2, 0x0ff)] : [and(l:w1, 0x0ff), l:w1 / 256, and(l:w2, 0x0ff), l:w2 / 256]
      endif
    else
      " UTF-32
      let l:w1 = a:codepoint / 65536
      let l:w2 = and(a:codepoint, 0x0ffff)
      let l:utfBytes = (a:endian ==# 'b') ? [l:w1 / 256, and(l:w1, 0x0ff), l:w2 / 256, and(l:w2, 0x0ff)] : [and(l:w2, 0x0ff), l:w2 / 256, and(l:w1, 0x0ff), l:w1 / 256]
    endif
  endif

  return l:utfBytes
endfunction

" ----------------------------------
" Write buffer to file in its binary format
"
function s:writeFile()
  let l:filename = expand("%:t")
  if l:filename == ''
    call s:PrintWarningMsg('HexX: Cannot write buffer - no filename')
  else
    call s:convertToBin()
    let &l:readonly = b:HexxReadOnly

    " Write file
    write
    let b:HexxModified = &modified

    set readonly
    call s:convertToHex()
    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)

    call s:PrintStatusMsg('HexX: Written to '.l:filename)
  endif
endfunction

" ----------------------------------
" Signal optional callback state change
"
" condtion - Condition being conveyed
"            This may be one of the following values;-
"            'start'   - About to enter Hex mode (function called before transition)
"            'end'     - Have exited Hex mode (function called after transition)
"            'suspend' - Hex mode suspended (function called after transition)
"            'resume'  - Hex mode entered again after suspension (fuction called before transition)
"
function s:stateChange(condition)
  if exists('*g:Hexx_StateChange')
    call g:Hexx_StateChange(a:condition)
  endif
endfunction

" ----------------------------------
" Convert hex to binary and leave Hexx mode
"
function s:endHex()
  " Stop highlighting
  call s:unhighlightHexCursor()
  call s:unhighlightASCIICursor()

  call s:convertToBin()

  " Ensure display is tidied up
  mode

  " Put buffer status back to how it was before Hexx started
  let &l:readonly = b:HexxReadOnly
  let &l:modifiable = b:HexxModifiable
  let &l:filetype = b:HexxFiletype
  let &l:undolevels = b:HexxUndoLevels
  let &l:wrap = b:HexxWrap

  " Override the 'modified' flag because it will always be set regardless
  " (because of the hex/bin conversion)
  let &l:modified = b:HexxModified

  call s:PrintStatusMsg('HexX: Exit edit mode')

  unlet b:HexxReadOnly
  unlet b:HexxModifiable
  unlet b:HexxEndOfLine
  unlet b:HexxFiletype
  unlet b:HexxUndoLevels
  unlet b:HexxWrap

  unlet b:HexxModified
  unlet b:HexxMode
  unlet b:HexxEditMode

  unlet! b:HexxTopLine

  unlet b:HexxNumBytes
  unlet b:HexxCursor
  unlet b:HexxCursorNibble
  unlet b:HexxUTFformat
  unlet b:HexxUTFendian
  unlet! b:HexxNum
  unlet! b:HexxUndoData
  unlet! b:HexxRedrawTimId

  call s:stateChange('end')
endfunction

" ----------------------------------
" Suspend HexX editing mode, remaining in Hex display mode
"
function s:suspendHex()
  call s:PrintStatusMsg("HexX: Suspended edit mode")
  set readonly
  set nomodifiable
  let b:HexxMode = s:modeSuspended
  call s:setEditMode(s:editModeOp)

  " Set 'modified' flag - can't rely on vim's 'modified' status because the
  " buffer will always be 'modified' because of the hex/bin conversion
  let &l:modified = b:HexxModified

  if !s:suspendCursor
    " Stop highlighting
    call s:unhighlightHexCursor()
    call s:unhighlightASCIICursor()
  endif

  call s:stateChange('suspend')
endfunction

" ----------------------------------
" Get keypress as a string. This is defined because getcharstr() is a relatively
" recent addition to vim
"
" Returns key press as a string
"
function s:getcharstr()
  let l:key = getchar()
  if type(l:key) == v:t_number
    let l:key = nr2char(l:key)
  endif

  return l:key
endfunction

" ----------------------------------
" Flush the keyboard buffer and inject the specified key presses into it
"
" keys - The key sequence to inject
"
function s:injectKeys(keys)
  " Flush keyboard buffer
  while getchar(0)
  endwhile

  call feedkeys(a:keys)
endfunction

" ----------------------------------
" Return a buffer-local value, with a minimum limit
"
" name - Name of value to retrieve
" min - Minimum value to allow
"
function s:getBVal(name, min)
  let l:val = get(b:, a:name, 0)
  return ((l:val >= a:min) ? l:val : a:min)
endfunction

" ----------------------------------
" Interpret cursor movement keys
"
" key - Key to interpret
" a:1 ignore_count - Optional. Defaults to 0. If 1, then b:HexxNum is ignored
"                    and the movement count is always 1. b:HexxNum will still
"                    be cleared if 'key' is indeed a cursor movement, otherwise
"                    it shall be left as-is
"                    If 1, then then b:HexxNum is used. A value of zero is
"                    treated as 1
" a:2 ignore h,j,k,l - Optional. defaults to 0. If 1, then h, j, k, l, H, and L
"     H and L          keys will not be recognised as cursor movement
"
" Returns 'continuation' status. If zero is returned then it indicates that
" 'key' is not a cursor movement
"
function s:cursorKey(key, ...)
  " 0 - Do not continue edit mode
  " 1 - Continue edit mode
  " 2 - Insert 'null' command and continue edit mode
  let l:cont = 1

  let l:key = a:key

  " Indicates whether or not to allow h, j, k, l, H, and L
  let l:allowChars = ((a:0 > 1) && a:2) ? 0 : 1

  " Cursor (nibble) movement
  if (l:key ==# "\<C-left>") || (l:allowChars && (l:key ==# 'H'))
    if b:HexxCursorNibble
      " Move to ms nibble within same byte
      let b:HexxCursorNibble = 0
    elseif b:HexxCursor
      " Move to ls nibble of previous byte
      let b:HexxCursor -= 1
      let b:HexxCursorNibble = 1
    endif

    let l:cont = 2
  elseif (l:key ==# "\<C-right>") || (l:allowChars && (l:key ==# 'L'))
    if !b:HexxCursorNibble
      " Move to ls nibble within same byte
      let b:HexxCursorNibble = 1
    elseif (b:HexxCursor + 1) < b:HexxNumBytes
      " Move to ms nibble of next byte
      let b:HexxCursor += 1
      let b:HexxCursorNibble = 0
    endif

    let l:cont = 2
  endif

  if l:cont == 2
    " Nibble movement - update display
    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
    unlet! b:HexxNum
  else
    " Possibly a byte movement or page up/down; not a nibble movement

    " Used for page up/down to reposition display
    let l:topLine = 0

    " Number of bytes or pages to move across / down
    let l:moveCount = (a:0 && a:1) ? 1 : s:getBVal('HexxNum', 1)

    if (l:key ==# "\<left>") || (l:allowChars && (l:key ==# 'h'))
      if (b:HexxCursor > l:moveCount)
        let b:HexxCursor -= l:moveCount
      else
        let b:HexxCursor = 0
      endif

      let l:cont = 2
    elseif (l:key ==# "\<right>") || (l:allowChars && (l:key ==# 'l'))
      let b:HexxCursor += l:moveCount
      if (b:HexxCursor >= b:HexxNumBytes)
        let b:HexxCursor = b:HexxNumBytes - 1
      endif

      let l:cont = 2
    elseif (l:key ==# "\<up>") || (l:allowChars && (l:key ==# 'k'))
      let l:moveCount *= s:bytes_per_line
      if (b:HexxCursor > l:moveCount)
        let b:HexxCursor -= l:moveCount
      else
        let b:HexxCursor = 0
        let l:cont = 2
      endif
    elseif (l:key ==# "\<down>") || (l:allowChars && (l:key ==# 'j'))
      let l:moveCount *= s:bytes_per_line
      let b:HexxCursor += l:moveCount
      if (b:HexxCursor >= b:HexxNumBytes)
        let b:HexxCursor = b:HexxNumBytes - 1
        let l:cont = 2
      endif
    elseif (l:key ==# "\<pageup>") || (l:key ==# "\<S-up>")
      let l:nlines = winheight(0) * l:moveCount
      let l:nlines = (l:nlines > 1) ? l:nlines - 1 : 1
      let l:moveCount *= (s:bytes_per_line * l:nlines)

      if (b:HexxCursor > l:moveCount)
        let b:HexxCursor -= l:moveCount
        let l:topLine = line('w0') - l:nlines + &scrolloff
      else
        let b:HexxCursor = 0
        let l:cont = 2
      endif
    elseif (l:key ==# "\<pagedown>") || (l:key ==# "\<S-down>")
      let l:nlines = winheight(0) * l:moveCount
      let l:nlines = (l:nlines > 1) ? l:nlines - 1 : 1
      let l:moveCount *= (s:bytes_per_line * l:nlines)

      let b:HexxCursor += l:moveCount
      if (b:HexxCursor >= b:HexxNumBytes)
        let b:HexxCursor = b:HexxNumBytes - 1
        let l:cont = 2
      else
        let l:topLine = line('w0') + l:nlines + &scrolloff
      endif
    else
      let l:cont = 0
    endif

    if l:cont
      if l:topLine
        " Reposition display for page up/down
        call cursor(l:topLine, 1)
        exe "normal! zt"
      endif

      " Cursor movement - update display
      let b:HexxCursorNibble = 0
      call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)

      unlet! b:HexxNum
    endif
  endif

  return l:cont
endfunction

" ----------------------------------
" Set undo data
"
" Copy the byte from the cursor position to the undo data
"
function s:setUndo()
  " Only save the byte if the current undo data does not refer to the same byte
  if !exists('b:HexxUndoData') || (b:HexxUndoData[0] != b:HexxCursor)
    let b:HexxUndoData = [b:HexxCursor, s:getByteValAtOffset(b:HexxCursor)]
  endif
endfunction

" ----------------------------------
" Move cursor on one nibble, and update cursor on display
"
" force - 1 = always update displayed cursor. 0 = only update displayed
"         cursor if eof not reached (ie, if it has actually moved)
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor - 1 = eof.
"
function s:nextNibble(force)
  let l:eof = 0

  if !b:HexxCursorNibble
    " Move to next nibble
    let b:HexxCursorNibble = 1
  else
    " Move to next byte
    if ((b:HexxCursor + 1) < b:HexxNumBytes)
      let b:HexxCursorNibble = 0
      let b:HexxCursor += 1
    else
      " End of buffer - stop replacing
      let l:eof = 1
    endif
  endif

  if !l:eof || a:force
    " Position for next nibble replacement
    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
  endif

  return l:eof
endfunction

" ----------------------------------
" Move cursor on one byte, and update cursor on display
"
" The nibble position within the byte is not altered
"
" force - 1 = always update displayed cursor. 0 = only update displayed
"         cursor if eof not reached (ie, if it has actually moved)
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor - 1 = eof.
"
function s:nextByte(force)
  let l:eof = 0

  if ((b:HexxCursor + 1) < b:HexxNumBytes)
    " Move to next byte
    let b:HexxCursor += 1
  else
    " End of buffer
    let l:eof = 1
  endi

  if !l:eof || a:force
    " Position for next nibble replacement
    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
  endif

  return l:eof
endfunction

" ----------------------------------
" Edit a single nibble
"
" nib - Nibble (ASCII hex in the 'correct' case)
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor after editing - 1 = eof.
"
function s:editNibble(nib)
  " Replace nibble
  call s:setUndo()
  exe 'normal! r'.a:nib."\<esc>"
  call s:updateASCIIChar()
  let l:eof = s:nextNibble(1)

  " Buffer has been modified
  let b:HexxModified = 1

  return l:eof
endfunction

" ----------------------------------
" Edit 1 or more nibbles
"
" count - The number of nibbles to modify
" nib - Nibble (ASCII hex in the 'correct' case)
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor after (or part-way through) editing - 1 = eof.
"
function s:editMultiNibbles(count, nib)
  let l:eof = 0

  let l:idx = 0
  if b:HexxCursorNibble
    " We are starting from a ls nibble - replace it
    exe 'normal! r'.a:nib."\<esc>"
    call s:updateASCIIChar()
    let l:eof = s:nextNibble(1)
    let l:idx += 1
  endif

  " Modify whole bytes
  if !l:eof
    let l:idx += 1
    let l:nibn = s:nibbleToInt(a:nib)
    let l:byte = (l:nibn * 16) + l:nibn
    while !l:eof && (l:idx < a:count)
      exe 'normal! r'.a:nib."\<esc>\<right>r".a:nib."\<esc>"

      call s:updateASCIIChar(l:byte)
      let l:eof = s:nextByte(1)
      let l:idx += 2
    endwhile
  endif

  " Modify any odd nibble at the end
  if !l:eof && (l:idx <= a:count)
    exe 'normal! r'.a:nib."\<esc>"
    call s:updateASCIIChar()
    let l:eof = s:nextNibble(1)
  endif

  " Buffer has been modified
  let b:HexxModified = 1

  " Doesn't make sense to allow this to persist
  unlet! b:HexxUndoData

  return l:eof
endfunction

" ----------------------------------
" Edit a single byte
"
" Note: This will force b:HexxCursorNibble to 0 (ms nibble) if not already the case
"
" byte - Byte to replace the in-focus byte with (numeric)
" next - 1 = After replacing byte, move cursor to next one
"        0 = After replacing byte, leave cursor in ms nibble of original byte
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor after editing - 1 = eof.
"
function s:editByte(byte, next)
  let l:eof = 0

  call s:setUndo()

  " Convert numeric byte value to hex characters
  const l:hchars = (s:hex_case == 'l') ? s:hexL : s:hexU
  let l:ms = l:hchars[and(a:byte / 16, 0x0f)]
  let l:ls = l:hchars[and(a:byte, 0x0f)]
  if b:HexxCursorNibble
    exe 'normal! r'.l:ls."\<esc>\<left>r".l:ms."\<esc>"
  else
    exe 'normal! r'.l:ms."\<esc>\<right>r".l:ls."\<left>\<esc>"
  endif

  let b:HexxCursorNibble = 0
  call s:updateASCIIChar(a:byte)
  if a:next
    let l:eof = s:nextByte(1)
  else
    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
  endif

  " Buffer has been modified
  let b:HexxModified = 1

  return l:eof
endfunction

" ----------------------------------
" Edit 1 or more bytes
"
" Note: This will force b:HexxCursorNibble to 0 (ms nibble) if not already the case
"
" count - The number of bytes to modify
" ms - High nibble (ASCII hex in the 'correct' case)
" ls - Low nibble (ASCII hex in the 'correct' case)
"
" Returns indication of whether already at end of buffer and therefore
" unable to move cursor after (or part-way through) editing - 1 = eof.
"
function s:editMultiBytes(count, ms, ls)
  if (a:count == 1)
    call s:setUndo()
  else
    " Doesn't make sense to allow this to persist
    unlet! b:HexxUndoData
  endif

  " Calculate character for ASCII part of display
  let l:byte = (s:nibbleToInt(a:ms) * 16) + s:nibbleToInt(a:ls)

  if b:HexxCursorNibble
    exe "normal! \<left>\<esc>"
    let b:HexxCursorNibble = 0
  endif

  " Replace bytes
  let l:eof = 0
  let l:idx = 0
  while !l:eof && (l:idx < a:count)
    exe 'normal! r'.a:ms."\<esc>\<right>r".a:ls."\<esc>"
    call s:updateASCIIChar(l:byte)
    let l:eof = s:nextByte(1)
    let l:idx += 1
  endwhile

  " Buffer has been modified
  let b:HexxModified = 1

  return l:eof
endfunction

" ----------------------------------
" Replace byte(s) with character ('C') or code point ('U')
"
" Operates at the current cursor position
"
" editFn - 'C' or 'U' to indicate the operation
" key - The entered key (only used if a:editFn == 'C')
"
" If a:editFn == 'U' then b:HexxNum is assumed to contain a code point
"
" Returns continuation status - 0 or 2
"
function s:CUKey(editFn, key)
  " 0 - Do not continue edit mode
  " 1 - Continue edit mode
  " 2 - Insert 'null' command and continue edit more
  let l:cont = 2

  " Entry may be a multi-byte character. If it is then replace each byte in turn
  if a:editFn ==# 'C'
    let l:key = char2nr(a:key)
    if (l:key == 0x1b) && s:exitWithEsc
      let l:cont = 0
    else
      let l:utfBytes = s:splitUTF(b:HexxUTFformat, ((l:key == 0x0d) && s:convertNewline) ? 0x0a : l:key, b:HexxUTFendian)
    endif
  else
    " 'U'
    let l:utfBytes = s:splitUTF(b:HexxUTFformat, b:HexxNum, b:HexxUTFendian)
  endif

  if l:cont
    let l:utfLen = len(l:utfBytes)
    if l:utfLen
      if (b:HexxCursor + l:utfLen) <= b:HexxNumBytes
        " Replace bytes with UTF character representation
        let l:idx = 0

        while l:cont && (l:idx < l:utfLen)
          if s:editByte(l:utfBytes[l:idx], 1)
            " End of file
            let l:cont = 0
          endif

          let l:idx += 1
        endwhile
      else
        call s:PrintWarningMsg('HexX: Encoding character as '.l:utfLen.' UTF'.b:HexxUTFformat.' bytes will exceed end of buffer')
      endif
    else
      call s:PrintWarningMsg('HexX: Value cannot be encoded as UTF'.b:HexxUTFformat)
    endif
  endif

  return l:cont
endfunction

" ----------------------------------
" Swap bytes ('S') operation
"
" Operates at the current cursor position. b:HexxNum is the number
" of bytes to swap, and is expected to be defined and > 1
"
function s:SKey()
  if (b:HexxCursor + b:HexxNum) <= b:HexxNumBytes
    " Swap bytes
    let l:bytes = repeat([''], b:HexxNum)
    let l:idx = 0

    " Copy bytes
    while l:idx < b:HexxNum
      let l:posn = s:byteToLC(b:HexxCursor + l:idx, 0)
      call cursor(l:posn[0], l:posn[1])
      let l:bytes[l:idx] = (s:nibbleToInt(s:getCharAtCursor(0)) * 16) + s:nibbleToInt(s:getCharAtCursor(1))
      let l:idx += 1
    endwhile

    " Write bytes back in reverse order
    let l:posn = []
    let l:idx2 = 0
    const l:hchars = (s:hex_case == 'l') ? s:hexL : s:hexU
    while l:idx
      let l:idx -= 1

      " Update Hex part of buffer
      let l:posn = s:byteToLC(b:HexxCursor + l:idx, 0)
      call cursor(l:posn[0], l:posn[1])
      let l:ms = l:hchars[and(l:bytes[l:idx2] / 16, 0x0f)]
      let l:ls = l:hchars[and(l:bytes[l:idx2], 0x0f)]
      exe 'normal! r'.l:ms."\<esc>\<right>r".l:ls."\<esc>"

      " Update ASCII part of buffer
      call s:posnCursor(b:HexxCursor + l:idx, -1)
      exe 'normal! r'.(s:numToChar(l:bytes[l:idx2]))."\<esc>"
      let l:idx2 += 1
    endwhile

    " Place cursor back where it was before we started
    call cursor(l:posn[0], l:posn[1])

    " Buffer has been modified
    let b:HexxModified = 1
  else
    call s:PrintWarningMsg("HexX: Can't swap ".b:HexxNum.' bytes - will exceed end of buffer')
  endif
endfunction

" ----------------------------------
" Append ('A') or Insert ('i') operation (1 or more bytes)
"
" Operates at the current cursor position
"
" editFn - 'A' or 'i' to indicate the operation
"
function s:aiKey(editFn)
  " Append/Insert one or more bytes

  " Determine if the append/insert is being made immediately after a newline
  " character (ie, if cursor is on a newline character)
  let l:eolCursor = (b:HexxNumBytes && (s:getByteValAtCursor() ==# s:newlineVal))

  call s:convertToBin()

  if b:HexxNumBytes
    " b:HexxCursor is zero-based, hence +1
    exe 'goto '.(b:HexxCursor + 1)
  endif

  " Number of bytes to  append/insert
  let l:num = s:getBVal('HexxNum', 1)
  unlet! b:HexxNum

  if a:editFn ==# 'i'
    " Insert
    if l:eolCursor
      " This will actually perform an insert before the newline character that the cursor is on
      exe "normal! ".l:num."a\<C-v>".s:newByteStr."\<esc>"
    else
      exe "normal! ".l:num."i\<C-v>".s:newByteStr."\<esc>"
    endif
  else
    " Append
    if l:eolCursor
      if ((b:HexxCursor + 1) >= b:HexxNumBytes)
        " At very end of a non-empty biffer - add a newline
        exe "normal! o\<esc>".l:num."i\<C-v>".s:newByteStr."\<esc>"

        " Strip newline that vim will have added after the above 'o' newline
        set noendofline
      else
        " Not at very end of buffer - move along one byte and perform an insert
        exe "normal! w".l:num."i\<C-v>".s:newByteStr."\<esc>"
      endif
    else
      " Just append new byte
      exe "normal! ".l:num."a\<C-v>".s:newByteStr."\<esc>"
    endif
  endif

  let b:HexxNumBytes += l:num
  let b:HexxCursorNibble = 0
  call s:convertToHex()

  " For append, move to first new byte. This check is needed in case buffer was previously empty
  if ((a:editFn ==# 'A') && ((b:HexxCursor + 1) < b:HexxNumBytes))
    let b:HexxCursor += 1
  endif

  " Buffer has been modified
  let b:HexxModified = 1

  call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
endfunction

" ----------------------------------
" Delete byte(s) ('x') operation
"
" Operates at the current cursor position
"
function s:xKey()
  if b:HexxNumBytes
    " Buffer not empty

    " Number of bytes to delete
    let l:numBytes = s:getBVal('HexxNum', 1)

    " Indication that delete is to the end of the buffer
    let l:delToEnd = 0

    " Determine if, after the operation, last character in buffer will be a newline character
    let l:eolBuff = 0
    if (b:HexxCursor + l:numBytes) >= b:HexxNumBytes
      " Delete to end of buffer
      let l:delToEnd = 1
      let l:numBytes = b:HexxNumBytes - b:HexxCursor

      if l:numBytes <= 2
        let l:eolBuff = b:HexxCursor && ((s:getByteValAtOffset(b:HexxCursor - 1) ==# s:newlineVal))
      endif
    else
      " Don't delete to end of buffer
      let l:eolBuff = ((s:getByteValAtOffset(b:HexxNumBytes - 1) ==# s:newlineVal))
    endif

    " Character at cursor
    let l:cursorVal = s:getByteValAtCursor()

    " Determine if the start or end of the delete lands on a newline character
    " and if so, reduce the text area being deleted to avoid them and deal with
    " the newline(s) specially
    let l:eolStart = (l:cursorVal ==# s:newlineVal)
    let l:eolEnd = (l:numBytes > 1) && (s:getByteValAtOffset(b:HexxCursor + l:numBytes - 1) ==# s:newlineVal)

    " Delete 1 or more characters
    let l:cursor = b:HexxCursor
    let l:xLen = l:numBytes

    " If the start and/or end of the range lands on a newline then treat those
    " byte positions specially
    if l:eolStart
      let l:cursor += 1
      let l:xLen -= 1
    endif

    if l:eolEnd
      let l:xLen -= 1
    endif

    if !l:xLen
      " Delete one or two newline characters only
      call s:convertToBin()
      exe 'goto '.((l:cursor > 1) ? l:cursor - ((l:delToEnd) ? 1 : 0) : 1)

      if !s:x_noyank
        call setreg(v:register, '')
      endif
    elseif (l:xLen ==# 1) && !l:eolEnd
      " Delete a single (non-newline) character
      if !s:x_noyank
        call setreg(v:register, nr2char(s:getByteValAtOffset(l:cursor)))
      endif

      call s:convertToBin()

      exe 'goto '.(l:cursor + 1)
      exe 'normal! "'.((s:x_noyank) ? '_' : v:register).'x'
    else
      " Delete 2 or more characters (or just a newline)
      call s:convertToBin()

      exe 'goto '.(l:cursor + 1)
      exe 'normal! vm<'
      exe 'goto '.(l:cursor + l:xLen)
      exe 'normal! m>gv"'.((s:x_noyank) ? '_' : v:register).'x'
    endif

    " Ensure newline is retained/not added at end of buffer
    let &l:endofline = l:eolBuff

    " Delete any starting or ending newlines
    if l:eolEnd
      exe "normal! gJ"
      if !s:x_noyank
        call setreg(v:register, s:newlineChar, 'a')
      endif
    endif

    if l:eolStart
      exe 'goto '.((l:cursor > 1) ? l:cursor - 1 : 1)
      exe "normal! gJ"
      if !s:x_noyank
        call setreg(v:register, s:newlineChar.getreg(v:register))
      endif
    endif

    " Buffer has been modified
    let b:HexxModified = 1

    " Tidy up and switch back to Hex mode
    let b:HexxNumBytes -= l:numBytes
    call s:convertToHex()

    if (b:HexxCursor >= b:HexxNumBytes)
      " Cursor has fallen off end of buffer - correct it
      let b:HexxCursor = (b:HexxNumBytes) ? b:HexxNumBytes - 1 : 0
    endif

    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
  endif

  unlet! b:HexxNum
endfunction

" ----------------------------------
" Perform undo of byte
"
" If it's defined, use the undo data to reinstate the value of the byte specified
" by it. The undo data is then updated with the byte value before the undo
" (basically swap the undo data with the current byte value)
"
function s:undoByte()
  if exists('b:HexxUndoData') && (b:HexxUndoData[0] < b:HexxNumBytes)
    " Set cursor from undo data
    let b:HexxCursor = b:HexxUndoData[0]
    let b:HexxCursorNibble = 0
    let l:val = b:HexxUndoData[1]

    call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)

    " Delete the undo data so that the call to s:editByte() will re-create it
    " again for the current byte value, and then perform undo operation
    unlet b:HexxUndoData
    call s:editByte(l:val, 0)
  else
    unlet! b:HexxUndoData
    call s:PrintWarningMsg("HexX: Can't undo")
  endif
endfunction

" ----------------------------------
" Yank ('y') operation (1 or more bytes)
"
" Operates at the current cursor position
"
function s:yKey()
  if b:HexxNumBytes
    " Buffer not empty

    " Number of bytes to yank
    let l:numBytes = s:getBVal('HexxNum', 1)

    if (b:HexxCursor + l:numBytes) > b:HexxNumBytes
      " Yank to end of buffer
      let l:numBytes = b:HexxNumBytes - b:HexxCursor
    endif

    " Determine if the start of the yank lands on a newline character
    let l:eolStart = (s:getByteValAtCursor() ==# s:newlineVal)

    if l:numBytes > 1
      " Yank 2 or more characters
      let l:cursor = b:HexxCursor
      if l:eolStart
        let l:cursor += 1
        let l:numBytes -= 1
      endif

      " Determine if the end of the yank lands on a newline character
      let l:eolEnd = ((l:numBytes > 1) && (s:getByteValAtOffset(l:cursor + l:numBytes - 1) ==# s:newlineVal))
      if l:eolEnd
        let l:numBytes -= 1
      endif

      if !l:numBytes
        " numBytes is zero - we are yanking two newline characters
        call setreg(v:register, '')
      elseif l:numBytes == 1
        " Yank a single character of the selected text
        call setreg(v:register, nr2char(s:getByteValAtOffset(l:cursor)))
      else
        " Yank 2 or more characters of the selected text
        call s:convertToBin()

        exe 'goto '.(l:cursor + 1)
        exe 'normal! vm<'
        exe 'goto '.(l:cursor + l:numBytes)
        exe 'normal! m>gv"'.v:register.'y'

        call s:convertToHex()
        call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
      endif

      " Add any starting or ending newlines to the yankded text
      if l:eolStart
        call setreg(v:register, s:newlineChar.getreg(v:register))
      endif

      if l:eolEnd
        call setreg(v:register, s:newlineChar, 'a')
      endif

      call s:PrintStatusMsg('HexX: Yanked '.l:numBytes.' bytes')
    else
      " Yank a single character
      if l:eolStart
        " Simulate 'yank' of newline
        call setreg(v:register, s:newlineChar)
        call s:PrintStatusMsg('HexX: Yanked 1 byte')
      else
        " It is not possible to set a register to a single nul (0x00) character
        " with nr2char() - see ':help nr2char()' for details - so we need to handle
        " that specific condition specially
        let l:cval = s:getByteValAtCursor()
        if l:cval
          call setreg(v:register, nr2char(l:cval))
        else
          " Single nul character - yank it the hard way
          call s:convertToBin()
          exe 'goto '.(b:HexxCursor + 1)
          exe 'normal! v"'.v:register.'y'
          call s:convertToHex()
          call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
        endif

        call s:PrintStatusMsg('HexX: Yanked 1 byte')
      endif
    endif
  endif

  unlet! b:HexxNum
endfunction

" ----------------------------------
" Paste ('p' and 'P') operation
"
" Operates at the current cursor position
"
" editFn - 'p' or 'P' to indicate the operation
"
function s:pKey(editFn)
  " Paste

  " Only support pasting numbers and strings (the former being converted to a string first)
  let l:paste = getreg(v:register)
  let l:type = type(l:paste)
  if (l:type == v:t_number)
    let l:paste = ''.l:paste
    let l:type = v:t_string
  endif

  if l:type == v:t_string
    let l:pasteLen = len(l:paste)
    if l:pasteLen
      " Determine if the cursor is on a newline character
      let l:eolCursor = (b:HexxNumBytes && (s:getByteValAtCursor() ==# s:newlineVal))

      " Determine if the text being pasted is terminated with a newline
      let l:eolPaste = (l:paste[l:pasteLen - 1] ==# s:newlineChar)

      call s:convertToBin()

      if a:editFn ==# 'p'
        " 'p' (paste after cursor)
        " b:HexxCursor is zero-based, hence +1
        exe 'goto '.(b:HexxCursor + 1 + ((l:eolCursor) ? 1 : 0))

        if l:eolCursor
          " Cursor is on a newline
          if ((b:HexxCursor + 1) >= b:HexxNumBytes)
            " Pasting at very end of buffer
            exe "normal! a".s:newlineChar."\<C-r>".v:register."\<esc>"

            if l:eolPaste
              exe 'normal! "_dd'
            else
              set noendofline
            endif
          else
            exe "normal! i\<C-r>".v:register."\<esc>"
          endif
        else
          " Cursor is not on a newline
          if !l:eolPaste && ((b:HexxCursor + 1) >= b:HexxNumBytes)
            " Pasted text does not end in a newline and pasting at very end of buffer
            set noendofline
          endif

          exe "normal! a\<C-r>".v:register."\<esc>"
        endif
      else
        " 'P' (paste before cursor)
        exe 'goto '.(b:HexxCursor + 1)
        if l:eolCursor
          " This will actually perform a paste before the newline character that the cursor is on
          exe "normal! a\<C-r>".v:register."\<esc>"
        else
          exe "normal! i\<C-r>".v:register."\<esc>"
        endif
      endif

      let b:HexxNumBytes += l:pasteLen
      call s:convertToHex()

      " Buffer has been modified
      let b:HexxModified = 1

      call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
      call s:PrintStatusMsg('HexX: Pasted '.l:pasteLen.((l:pasteLen > 1) ? ' bytes' : ' byte'))
    endif " pasteLen > 0
  else
    call s:WarningMsg("HexX: Sorry - Can only paste numbers and strings")
  endif
endfunction

" ----------------------------------
" Data entry key handler
"
" This handles the operations 'r', 'R', 'C', 'U', 'S',  i', 'A'
"
" editFn - The edit function that the key entry is for
"
function s:dataKey(editFn)
  let l:key = s:getcharstr()

  " 0 - Do not continue edit mode
  " 1 - Continue edit mode
  " 2 - Insert 'null' command and continue edit more
  let l:cont = 1

  " The next command (processed by s:key()) to automatically process (if any)
  let l:nextCmd = ''

  " The edit operation may be changed by this function, hence make a copy of the
  " supplied value
  let l:editFn = a:editFn

  " ### Is this needed now????
"  if (l:key ==# s:suspendEditKey) || (l:key ==# s:exitEditKey)
"    " Exit edit mode
"    let l:cont = 0
"
  " Replace successive nibbles
  if l:editFn ==# 'r'
    " Assume cursor key or end of buffer or illegal value entered until proven otherwise
    let l:cont = 0

    if !s:cursorKey(l:key)
      " Not cursor key
      let l:nib = s:hexCharToChar(l:key)
      if l:nib !=# ''
        " Valid value entry
        let l:count = s:getBVal('HexxNum', 1)

        if !((l:count == 1) ? s:editNibble(l:nib) : s:editMultiNibbles(l:count, l:nib))
          " Not end of buffer
          let l:cont = 2
        endif
      endif

      " It's far too confusing to allow this to persist
      unlet! b:HexxNum
    endif

  " Replace successive bytes
  elseif l:editFn ==# 'R'
    " Assume cursor key or end of buffer or illegal value entered until proven otherwise
    let l:cont = 0

    if !s:cursorKey(l:key)
      " Not cursor key - Value entry
      let l:ms = s:hexCharToChar(l:key)
      if l:ms !=# ''
        " Valid nibble value - Get second nibble of byte
        let l:key2 = s:getcharstr()
        let l:ls = s:hexCharToChar(l:key2)
        if l:ls !=# ''
          " Byte value is valid
          if !s:editMultiBytes(s:getBVal('HexxNum', 1), l:ms, l:ls)
            " Not end of buffer - Switch to 'r' operation for remaining entries
            let l:editFn = 'r'
            let l:cont = 2
          endif
        endif
      endif

      " It's far too confusing to allow this to persist
      unlet! b:HexxNum
    endif

  " Replace successive bytes with character or code point
  elseif (l:editFn ==# 'C') || (l:editFn ==# 'U')
    let l:cont = 2

    if s:cursorKey(l:key, (l:editFn ==# 'U'), (l:editFn ==# 'C'))
      " Cursor key
      let l:cont = 0
    elseif (l:editFn ==# 'U')
      if (l:key ==# 'U')
        if !exists('b:HexxNum')
          " 'U' with no code point - exit
          call s:PrintWarningMsg("HexX: 'U' operation requires a count (code point)")
          let l:cont = 0
        elseif b:HexxNum > 0x10ffff
          call s:PrintWarningMsg("HexX: Code point value for 'U' operation is too large")
          let l:cont = 0
        endif
      else
        " We were in 'U' mode, now user is trying to do something else - exit
        unlet! b:HexxNum
        let l:nextCmd = l:key
        let l:cont = 0
      endif
    endif

    if l:cont
      " Perform operation
      let l:cont = s:CUKey(l:editFn, l:key)
    endif

  " Swap byte order
  elseif (l:editFn ==# 'S')
    let l:cont = 2

    if s:cursorKey(l:key, 1)
      " Cursor key
      let l:cont = 0
    elseif (l:key ==# 'S')
      if !exists('b:HexxNum') || (b:HexxNum < 2)
        " 'S' with no byte count - exit
        call s:PrintWarningMsg("HexX: 'S' operation requires a count (number of bytes) > 1")
        let l:cont = 0
      else
        " Perform operation
        call s:SKey()
      endif
    else
      " We were in 'S' mode, now user is trying to do something else - exit
      unlet! b:HexxNum
      let l:nextCmd = l:key
      let l:cont = 0
    endif

  " Append/Insert bytes
  elseif (l:editFn ==# 'i') || (l:editFn ==# 'A')
    if l:key ==# l:editFn
      call s:aiKey(l:editFn)
      call s:setEditMode(s:editModeIcmd)
    else
      " Edit the byte(s) just appended/inserted
      " Assume cursor key or end of buffer or illegal value entered until proven otherwise
      let l:cont = 0

      if !s:cursorKey(l:key)
        " Not cursor key
        let l:nib = s:hexCharToChar(l:key)
        if l:nib !=# ''
          " Valid value entry
          if !s:editNibble(l:nib)
            " Not end of buffer
            let l:cont = 2
          endif
        endif
      endif
    endif
  endif

  " Update edit mode
  if l:cont == 2
    call s:setEditMode(s:editModeData)
  elseif !l:cont || (b:HexxEditMode != s:editModeIcmd)
    call s:setEditMode(s:editModeOp)
  endif

  " Many (all?) or the parameters that may be displayed on the status line
  " (see function hexx#status()) will not automatically cause a refresh of
  " the status line display, so force it
  redrawstatus

  let l:keys = ''

  " Control re-execution of this or the general entry function (s:key())
  if l:cont !=# 1
    let l:keys = s:nullCmd
  endif

  " Continue
  let l:keys = l:keys.s:leaderBaseRes

  if l:cont
    let l:keys = l:keys.s:entryChar.l:editFn
  elseif l:nextCmd !=# ''
    " Exiting back to main key handler with a pre-set operation injected
    let l:keys = l:keys.l:nextCmd
  endif

  call s:injectKeys(l:keys)
endfunction

" ----------------------------------
" Check count value against limit and delete b:HexxNum if the limit is exceeded
"
" Returns true = count is ok, false = count is too high
"
function s:checkCountLimit()
  let l:ok = !(s:countLimit && (get(b:, 'HexxNum', s:countLimit) > s:countLimit))
  if !l:ok
    unlet b:HexxNum
    call s:PrintWarningMsg("HexX: Value of 'count' exceeds user-specified maximum for this operation")
  endif

  return l:ok
endfunction

" ----------------------------------
" Timer callback for 'redraw' ('\') operation
"
" This is scheduled to execute a short time after HexX has exited edit mode
" It forces a redraw of the display, and then reschedules HexX edit mode to
" restart
"
function hexx#schedRedraw(timer)
  mode
  call s:injectKeys(s:nullCmd.s:leaderBaseRes)
endfunction

" ----------------------------------
" General key handler
"
function s:key(key)
  " \' (redraw) and 'z' (scroll buffer left/right) are handled specially - see below
  let l:key = a:key
  if l:key ==# ''
    let l:key = s:getcharstr()
  endif

  " l:cont
  " 0 - Do not continue edit mode
  " 1 - Continue edit mode
  " 2 - Insert 'null' command and continue edit mode

  " The next command to automatically process (if any)
  let l:nextCmd = ''

  " Cursor movement
  let l:cont = s:cursorKey(l:key)
  if !l:cont
    " Not a cursor movement
    let l:cont = 1

    let l:editFn = (stridx('rRiaxpP', l:key) >= 0)
    if (l:editFn && !b:HexxModifiable)
      call s:PrintWarningMsg('HexX: Cannot edit - buffer is not modifiable')

    " Replace nibble with hex value (r), or replace byte with hex or character value (R, C)
    elseif (l:key ==? 'r') || (l:key ==# 'C')
      if s:checkCountLimit()
        unlet! b:HexxUndoData

        " If 'R' is specified with no significant count, treat it as 'r' instead
        if (l:key ==# 'R') && (get(b:, 'HexxNum', 1) <= 1)
          let l:key = 'r'
        endif

        let l:nextCmd = s:entryChar.l:key
        call s:setEditMode(s:editModeData)
      else
        " 'cont = 2' because warning message will have been printed
        let l:cont = 2
      endif

    " Replace byte(s) with unicode code point
    elseif (l:key ==# 'U')
      unlet! b:HexxUndoData

      " Note: repeat l:key in order to provide both a:editFn and l:key to s:dataKey();
      "       the second l:key is dummy to stop s:dataKey() stalling
      let l:nextCmd = s:entryChar.l:key.l:key
     call s:setEditMode( s:editModeData)

    " Swap bytes
    elseif (l:key ==# 'S')
      if s:checkCountLimit()
        unlet! b:HexxUndoData
        let l:nextCmd = s:entryChar.l:key.l:key
      else
        " 'cont = 2' because warning message will have been printed
        let l:cont = 2
      endif

    " Insert
    elseif (l:key ==# 'i')
      if s:checkCountLimit()
        unlet! b:HexxUndoData
        let l:nextCmd = s:entryChar.l:key.l:key
      else
        " 'cont = 2' because warning message will have been printed
        let l:cont = 2
      endif

    " Append
    elseif (l:key ==# 'A')
      if s:checkCountLimit()
        unlet! b:HexxUndoData
        let l:nextCmd = s:entryChar.l:key.l:key
      else
        let l:cont = 2
      endif

    " Delete
    elseif (l:key ==# 'x')
      if s:checkCountLimit()
        unlet! b:HexxUndoData
        call s:xKey()
      endif

      let l:cont = 2

    " Undo byte
    elseif l:key ==# 'u'
      call s:undoByte()
      let l:cont = 2

    " Goto specified byte
    elseif l:key ==# 'G'
      if exists('b:HexxNum')
        let b:HexxCursor = (b:HexxNumBytes) ? ((b:HexxNum < b:HexxNumBytes) ? b:HexxNum : b:HexxNumBytes - 1) : 0
        let b:HexxCursorNibble = 0
        call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)
        unlet b:HexxNum
      endif

      let l:cont = 2

    " Yank specified number of bytes
    elseif (l:key ==# 'y') && s:allowYankAndPaste
      call s:yKey()
      let l:cont = 2

    " Paste bytes
    elseif (l:key ==? 'p') && s:allowYankAndPaste
      unlet! b:HexxNum
      unlet! b:HexxUndoData
      call s:pKey(l:key)
      let l:cont = 2

    " Write file
    elseif l:key ==# 'w'
      if s:secondWarn != l:key
        call s:PrintWarningMsg('HexX: Press again to write file')
        let s:secondWarn = l:key
      else
        call s:writeFile()
      endif

      let l:cont = 2

    " Suspend edit mode
    elseif l:key ==# s:suspendEditKey
      call timer_stop(b:HexxRedrawTimId)

      unlet! b:HexxNum
      if s:secondWarn != l:key
        call s:PrintWarningMsg('HexX: Press again to suspend edit mode')
        let s:secondWarn = l:key
        let l:cont = 2
      else
        call s:suspendHex()
        let l:cont = 0
      endif

    " Exit edit mode
    elseif l:key ==# s:exitEditKey
      call timer_stop(b:HexxRedrawTimId)

      unlet! b:HexxNum
      if s:secondWarn != l:key
        call s:PrintWarningMsg('HexX: Press again to exit edit mode (and exit HexX)')
        let s:secondWarn = l:key
        let l:cont = 2
      else
        call s:endHex()
        let l:cont = 0
      endif

    " Scroll buffer left/right
    elseif l:key ==# 'z'
      let l:key = s:getcharstr()
      if (l:key ==? 'h') || (l:key ==? 'l') || (l:key == "\<left>") || (l:key == "\<right>")
        exe 'normal! z'.l:key
      endif

    " Refresh display
    elseif l:key ==# '\'
      " The most reliable way of doing this is to exit HexX editing mode and
      " then re-enter it after a short delay. This delay gives Vim enough time
      " to sort out the display, after which the timer callback restarts HexX
      call s:PrintStatusMsg('HexX: Redraw')
      let l:cont = 0
      let b:HexxRedrawTimId = timer_start(10, 'hexx#schedRedraw')

    else
      " Possibly numeric entry
      let l:key = s:hexCharToChar(l:key)
      if l:key !=# ''
        " Valid hex character entered - could be a prelude to an operation
        let b:HexxNum = get(b:, 'HexxNum', 0)
        let l:limit = ' - limited to 32 bits'
        if b:HexxNum <= 0x0fffffff
          let b:HexxNum = (b:HexxNum * 16) + s:nibbleToInt(l:key)
          let l:limit = ''
        endif

        call s:PrintStatusMsg("HexX: Num = ".(printf('0x%02'.((s:hex_case ==# 'u') ? 'X' : 'x'), b:HexxNum))." (".b:HexxNum.")".l:limit)
      else
        " Unrecognised key
        call s:PrintWarningMsg('HexX: In edit mode - unrecognised key')
        unlet! b:HexxNum
      endif

      let l:cont = 2
    endif
  endif

  if !l:cont || ((l:key !=# 'w') && (l:key !=# s:suspendEditKey) && (l:key !=# s:exitEditKey))
    " Reset 'write'/'suspend'/'exit' confirmation
    let s:secondWarn = ''
  endif

  " Many (all?) or the parameters that may be displayed on the status line
  " (see function hexx#status()) will not automatically cause a refresh of
  " the status line display, so force it
  redrawstatus

  " Control re-execution of this or the dataKey() function (above)
  if l:cont
    let l:keys = ''

    if l:cont == 2
      let l:keys = s:nullCmd
    endif

    " Continue (stay in edit mode)
    let l:keys = l:keys.s:leaderBaseRes

    if l:nextCmd !=# ''
      " Pre-select next operation
      let l:keys = l:keys.l:nextCmd
    endif

    call s:injectKeys(l:keys)
  endif
endfunction

" ----------------------------------
" Initiate edit mode - drop into HexX 'environment'
"
function s:editInit()
  " Initiate first invocation of s:key()
  call s:injectKeys(s:nullCmd.s:leaderBaseRes)
  let b:HexxMode = s:modeEnabled

  " Set to undefined first to force a state change
  let b:HexxEditMode = s:editModeUndef
  call s:setEditMode(s:editModeOp)
endfunction

" ----------------------------------
" Resume or create a new Hex editable buffer from an existing buffer
" and initiate edit mode
"
" Returns failure status (zero = success)
"
function hexx#start()
  " Returned failure status
  let l:fail = 1

  if &filetype ==# s:hexxFiletype
    " Already in 'hex' format
    if get(b:, 'HexxMode', s:modeNone) == s:modeSuspended
      " Perform a 'resume'
      call s:stateChange('resume')

      " The buffer must be modifiable in order to perform the conversion to/from hex format
      set modifiable

      " Re-position cursor
      call s:posnCursor(b:HexxCursor, b:HexxCursorNibble)

      call s:editInit()

      " Force a refresh of the status line
      redrawstatus

      call s:PrintStatusMsg('HexX: Resuming edit mode')
      let fail = 0
    else
      call s:PrintWarningMsg('HexX: Cannot resume edit mode - buffer state is not as expected')
    endif
  else
    " Not already in 'hex' format
    call s:stateChange('start')

    let b:HexxReadOnly = &readonly
    let b:HexxModifiable = &modifiable
    let b:HexxEndOfLine = &endofline
    let b:HexxFiletype = &filetype
    let b:HexxUndoLevels = &undolevels
    let b:HexxWrap = &wrap

    " Prepare buffer for editing
    set binary
    set readonly
    set nofixendofline
    let &l:filetype = s:hexxFiletype

    " Cursor control
    let b:HexxNumBytes = wordcount()['bytes']
    let b:HexxCursor = 0
    let b:HexxCursorNibble = 0

    " The UTF encoding format for the 'C' and 'U' operations; value is 8, 16 or 32, and
    " the endian to use for the same - 'b' or 'l'
    let b:HexxUTFformat = s:utfEncoding
    let b:HexxUTFendian = s:utfEndian

    " A 'modified' flag - can't rely on vim's 'modified' status; as far as vim is
    " concerned, the buffer will always be 'modified' because of the hex/bin conversion
    let b:HexxModified = &modified

    " The buffer must be modifiable in order to perform the conversion to hex format
    set modifiable

    " Switch off the undo for this file because it won't make any sense once
    " Hexx has finished with it
    let &l:undolevels = -1

    " Remove line wrap if requested
    if s:removeLineWrap
      set nowrap
    endif

    " Id of 'redraw' callback timer
    let b:HexxRedrawTimId = 0

    " Convert to hex
    call s:convertToHex()

    " Position cursor at start of buffer
    call s:posnCursor(0, 0)

    " Start editing
    call s:editInit()

    " Force a refresh of the status line
    redrawstatus

    if b:HexxModifiable
      call s:PrintStatusMsg("HexX: Edit mode")
    else
      call s:PrintStatusMsg("HexX: Edit mode. Original buffer is not modifiable - any edits will be lost")
    endif

    let l:fail = 0
  endif

  return l:fail
endfunction

" ----------------------------------
" Set UTF encoding scheme and endian used by 'C' and 'U' operations
"
" utf - UTF encoding scheme to set. Must be 8, 16 or 32
" 1 - Optional arguent - 'b' or 'l' to indicate big or little endian
"     when setting UTF-16 or UTF-32 values. Default is not changed
"     if this argument is not specified
"
" Returns failure status (zero = success)
"
function hexx#setUtf(utf, ...)
  " Returned failure status
  let l:fail = 1

  if &filetype ==# s:hexxFiletype
    " In 'hex' format
    if get(b:, 'HexxMode', s:modeNone) == s:modeSuspended
      if (a:utf == 8) || (a:utf == 16) || (a:utf == 32)
        if a:0
          " Endian also specified
          if (a:1 == 'b') || (a:1 == 'l')
            let b:HexxUTFformat = a:utf
            let b:HexxUTFendian = a:1
            let fail = 0
          else
            call s:PrintWarningMsg("HexX: Illegal UTF endian specified - must be 'b' or 'l'")
          endif
        else
          " Endian not specified
          let b:HexxUTFformat = a:utf
          let fail = 0
        endif
      else
        call s:PrintWarningMsg('HexX: Illegal UTF scheme specified - must be 8, 16 or 32')
      endif
    else
      call s:PrintWarningMsg('HexX: Cannot set UTF encoding scheme - buffer state is not as expected')
    endif
  else
    call s:PrintWarningMsg('HexX: Buffer must be in suspended state to set UTF encoding scheme')
  endif

  return l:fail
endfunction

" ----------------------------------
" Return state of HexX buffer. This is provided primarily for displaying information
" on the status line by means outside of HexX
"
" bn - Optional buffer number to read information from. If not specified, the
"      current in-focus buffer is assessed
"
" Returns:
" The Hexx status for the buffer is returned in a dictionary (associative array) with
" the following fields;-
"
" 'hexx' - Indicates whether or not 'HexX' filetype is set for this buffer (0 (no)
"           or 1 (yes)). If 0 (no) is returned then any other fields should be ignored
"           and assumed to not even be defined
" 'mode' - Indicates the mode that Hexx is in;-
"          0 = No mode set - buffer should be in its original text/binary mode.
"              indicates a problem if 'hexx' is not also 0 (either someone has
"              been manually messing about with the buffer status or there is a
"              bug!). In this case, the remaining fields (below) should be
"              ignored as they are likely unreliable
"          1 = Hexx mode enabled and active editing allowed
"          2 = Suspended (buffer is in Hexx mode but not being actively edited)
" 'edit' - Edit mode;-
"          0 - Only operation/cursor entry and 'count' accepted
"          1 - Only a repeat of the last operation (which will be 'A' or 'i') or byte
"              data entry accepted (modifying buffer)
"          2 - Only byte data entry accepted (modifying buffer)
" 'cursor' - Numeric byte number (zero-based) the cursor is on (this can only be relied
"            upon of both 'hexx' and 'mode' are 1 (true)
" 'len' - The length of the buffer in bytes
" 'count' - The current value of b:HexxNum (the count used to repeat the next operation).
"           A value of zero indicates not set (and so will be treated as a value of 1
"           on the next operation). Note that 'count' is reset to zero when edit
"           mode exists
" 'ro' - Indication that original file is read-only. 1 = yes
" 'modfbl' - Indication that original file is modifiable. 1 = yes
" 'mod' - Indication that file has been modified. 1 = yes
" 'utf' - The UTF encoding scheme that the 'C' and 'U' operation will use - 8, 16 or 32
" 'utfend' - The endian to use for 'C' and 'U' operations ef encoding UTF-16 or UTF-32
"            characters - 'b' or 'l' (big or little)
" 'undo' - The undo data. This is a 2 element array [byte index, value]. An empty
"          array is returned if no undo data available
"
" NOTE: If 'mode' is 2 (suspended) then the value of 'cursor' is that which shall be
"       re-instated when editing resumes. The visual representation may not currently
"       match this (if the user has moved the cursor after exiting 'edit' mode)i
"       but it shall be corrected on re-commencement of edit mode.
"       'len' should remain valid but if the user chooses to circumvent the
"       protections put in place (ie - the buffer is set to non-modifiable) then
"       this will break things when editing resumes (but what do you expect?!)
"
function hexx#status(...)
  let l:bn = (a:0) ? a:1 : bufnr()
  if bufexists(l:bn)
    let l:status = {'hexx':(getbufvar(l:bn, '&filetype') ==# s:hexxFiletype), 'mode':(getbufvar(l:bn, 'HexxMode', s:modeNone)), 'edit':(getbufvar(l:bn, 'HexxEditMode', 0)), 'cursor':(getbufvar(l:bn, 'HexxCursor', 0)), 'len':(getbufvar(l:bn, 'HexxNumBytes', 0)), 'count':(getbufvar(l:bn, 'HexxNum', 0)), 'ro':(getbufvar(l:bn, 'HexxReadOnly', 0)), 'modfbl':(getbufvar(l:bn, 'HexxModifiable', 0)), 'mod':(getbufvar(l:bn, 'HexxModified', 0)), 'utf':(getbufvar(l:bn, 'HexxUTFformat', 0)), 'utfend':(getbufvar(l:bn, 'HexxUTFendian', '')), 'undo':(getbufvar(l:bn, 'HexxUndoData', []))}
  else
    let l:status = {'hexx':0}
  endif

  return l:status
endfunction

" ----------------------------------
" Module Initialisation
"
function s:initialise()
  " Sanity checks on the most important options
  if !s:byte_grouping || and(s:byte_grouping, (s:byte_grouping - 1))
    call s:PrintWarningMsg('HexX: Error - g:Hexx_byteGrouping values is not a valid power of 2')
  elseif s:bytes_per_line % s:byte_grouping
    call s:PrintWarningMsg('HexX: Error - g:Hexx_bytesPerLine is not an exact multiple of g:Hexx_byteGrouping')
  elseif (s:hex_case !=# 'u') && (s:hex_case !=# 'l')
    call s:PrintWarningMsg('HexX: Error - g:Hexx_hexCase set to invalid value')
  else
    " The byte value (8 bits ONLY) to set for inserted or appended bytes
    " Note: A value of 0x0a is not allowed as it will break things!
    " (Because of the call to s:charToHex(), this value cannot be set at
    " the top of the file, hence it's set here)
    let l:newByteVal = get(g:, 'Hexx_newByteValue', 0x0a)
    const s:newByteStr = (l:newByteVal == 0x0a) ? 'u0000' : 'u00'.s:charToHex(nr2char(l:newByteVal))

    " Highlight group (hex and ASCII cursor byte). If s:hlHexnibble is '' then
    " s:hlHexcursor colour is used for the whole of the byte at the cursor position.
    " These valeu COULD be set at the start of the file but setting them here
    " allows then to be const
    let l:hlHexcursor = get(g:, 'Hexx_cursorHex', '')
    const s:hlHexcursor = (l:hlHexcursor ==# '') ? 'Search' : l:hlHexcursor

    let l:hlHexnibble = get(g:, 'Hexx_cursorNibbleHex', '')
    const s:hlHexnibble = (l:hlHexnibble ==# s:hlHexcursor) ? '' : l:hlHexnibble

    let l:hlASCIIcursor = get(g:, 'Hexx_cursorASCII', '')
    const s:hlASCIIcursor = (l:hlASCIIcursor ==# '') ? 'Search' : l:hlASCIIcursor

    " General key handler
    " NOTE: I have no idea how or why this works, but referencing v:register
    "       in the mapping like this seems to be necessary in order for the
    "       function (key() in this case) to receive the correct v:register
    "       value
    "
    exe 'nnoremap <silent> '.s:leaderBase.' :let @_ = v:register<cr>:call <sid>key("")<cr>'

    " The following also serve as ambiguity mappings for the previous

    " Redraw screen
    exe 'nnoremap <silent> '.s:leaderBase.'\ :call <sid>key("\\")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.'<C-l> :call <sid>key("\\")<cr>'

    " Horizontal scroll
    exe 'nnoremap <silent> '.s:leaderBase.'z :call <sid>key("z")<cr>'

    " Data entry key handler (and ambiguity mapping 0x01)
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'r'.nr2char(1).' :call <sid>dataKey("r")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'r :call <sid>dataKey("r")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'R'.nr2char(1).' :call <sid>dataKey("R")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'R :call <sid>dataKey("R")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'C'.nr2char(1).' :call <sid>dataKey("C")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'C :call <sid>dataKey("C")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'U'.nr2char(1).' :call <sid>dataKey("U")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'U :call <sid>dataKey("U")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'S'.nr2char(1).' :call <sid>dataKey("S")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'S :call <sid>dataKey("S")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'i'.nr2char(1).' :call <sid>dataKey("i")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'i :call <sid>dataKey("i")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'A'.nr2char(1).' :call <sid>dataKey("A")<cr>'
    exe 'nnoremap <silent> '.s:leaderBase.s:entryChar.'A :call <sid>dataKey("A")<cr>'
  endif
endfunction

call s:initialise()

" ----------------------------------
" eof
