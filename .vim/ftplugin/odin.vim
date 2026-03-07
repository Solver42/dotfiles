" Key bindings for commenting
nnoremap <buffer> <C-k> :call ToggleComment('//')<CR>
vnoremap <buffer> <C-k> :call ToggleComment('//')<CR>

" Tab settings
setlocal tabstop=4
setlocal shiftwidth=4
setlocal noexpandtab
setlocal smarttab
setlocal autoindent
setlocal smartindent

highlight OdinBuildError   ctermfg=9  ctermbg=NONE
highlight OdinBuildSuccess ctermfg=46 ctermbg=NONE

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" ============================================================
" Build helpers
" ============================================================

function! s:FindProjectRoot()
    let l:current_dir = expand('%:p:h')
    let l:max_depth = 10
    let l:depth = 0
    while l:depth < l:max_depth
        if filereadable(l:current_dir . '/main.odin')
            return l:current_dir
        endif
        let l:parent = fnamemodify(l:current_dir, ':h')
        if l:parent == l:current_dir | break | endif
        let l:current_dir = l:parent
        let l:depth += 1
    endwhile
    return expand('%:p:h')
endfunction

function! s:OdinCheck()
    if &modified | silent write | endif
    let l:current_file = expand('%:p')
    let l:dir = s:FindProjectRoot()
    if expand('%:t') != 'main.odin'
        let l:output = system('odin check ' . shellescape(l:current_file) . ' < /dev/null 2>&1')
    else
        let l:output = system('cd ' . shellescape(l:dir) . ' && odin check . < /dev/null 2>&1')
    endif
    let l:errors = []
    for l:line in split(l:output, "\n")
        let l:match = matchlist(l:line, '\([^(]\+\)(\(\d\+\):\(\d\+\))\s*\(.*\)')
        if !empty(l:match)
            call add(l:errors, {'filename': l:match[1], 'lnum': str2nr(l:match[2]),
                \ 'col': str2nr(l:match[3]), 'text': l:match[4]})
        endif
    endfor
    if !empty(l:errors)
        call setqflist(l:errors, 'r')
        silent! cfirst
        normal! zz
        redraw!
        echohl OdinBuildError | echo l:errors[0].text | echohl None
    else
        call setqflist([], 'r')
        redraw!
        echohl OdinBuildSuccess | echo "odin check successful" | echohl None
    endif
endfunction

function! s:OdinRun()
    if &modified | silent write | endif
    let l:dir = s:FindProjectRoot()
    let l:check_output = system('cd ' . shellescape(l:dir) . ' && odin check . < /dev/null 2>&1')
    let l:errors = []
    for l:line in split(l:check_output, "\n")
        let l:match = matchlist(l:line, '\([^(]\+\)(\(\d\+\):\(\d\+\))\s*\(.*\)')
        if !empty(l:match)
            call add(l:errors, {'filename': l:match[1], 'lnum': str2nr(l:match[2]),
                \ 'col': str2nr(l:match[3]), 'text': l:match[4]})
        endif
    endfor
    if !empty(l:errors)
        call setqflist(l:errors, 'r')
        silent! cfirst
        normal! zz
        redraw!
        echohl OdinBuildError | echo l:errors[0].text | echohl None
    else
        call setqflist([], 'r')
        execute '!cd ' . shellescape(l:dir) . ' && odin run .'
    endif
endfunction

function! s:OdinFormatExternal()
    if &modified | silent write | endif
    let l:odinfmt = expand('~/dev/tools/ols/odinfmt')
    if !executable(l:odinfmt) | echon "odinfmt not found" | return | endif
    let l:file      = expand('%:p')
    let l:output    = system(l:odinfmt . ' -stdin < ' . shellescape(l:file) . ' 2>&1')
    let l:exit_code = v:shell_error
    redraw!
    if l:output =~ '<stdin>(\d\+:\d\+):'
        let l:match = matchlist(l:output, '<stdin>(\(\d\+\):\(\d\+\)):\s*\([^\n]*\)')
        if !empty(l:match)
            call cursor(str2nr(l:match[1]), str2nr(l:match[2]))
            echohl OdinBuildError | echon "Cannot format: " . l:match[3] | echohl None
        endif
    elseif l:exit_code == 0 && len(l:output) > 0
        let l:save_view = winsaveview()
        silent %delete _
        call setline(1, split(l:output, '\n'))
        call winrestview(l:save_view)
        silent write
        echohl OdinBuildSuccess | echon "odin file formatted" | echohl None
    else
        echohl OdinBuildError | echon "Format failed" | echohl None
    endif
endfunction

" ============================================================
" Utilities for fk
" ============================================================

" Cumulative bracket depth of str (positive = more opens than closes).
function! s:BracketDepth(str)
    let l:d = 0
    for l:c in split(a:str, '\zs')
        if     l:c =~# '[({[]' | let l:d += 1
        elseif l:c =~# '[)}\]]' | let l:d -= 1
        endif
    endfor
    return l:d
endfunction

" Return 1 if str contains a : not part of ::.
function! s:HasSingleColon(str)
    let l:chars = split(a:str, '\zs')
    let l:i = 0
    while l:i < len(l:chars)
        if l:chars[l:i] ==# ':'
            if l:i + 1 >= len(l:chars) || l:chars[l:i + 1] !=# ':'
                return 1
            else
                let l:i += 1
            endif
        endif
        let l:i += 1
    endwhile
    return 0
endfunction

" Find the closing } for the { on line lnum.
" Starts at lnum+1 with depth=1 so a leading } on the same line
" (e.g. '} else {') does not corrupt the depth counter.
function! s:FindClose(lnum)
    let l:depth = 1
    let l:i = a:lnum + 1
    while l:i <= line('$')
        for l:c in split(getline(l:i), '\zs')
            if     l:c ==# '{' | let l:depth += 1
            elseif l:c ==# '}' | let l:depth -= 1
                if l:depth == 0 | return l:i | endif
            endif
        endfor
        let l:i += 1
    endwhile
    return -1
endfunction

" Return 1 if the line contains any balanced { } pair.
function! s:LineHasBraceBlock(line)
    let l:chars = split(a:line, '\zs')
    let l:i = 0
    while l:i < len(l:chars)
        if l:chars[l:i] ==# '{'
            let l:d = 1 | let l:j = l:i + 1
            while l:j < len(l:chars)
                if     l:chars[l:j] ==# '{' | let l:d += 1
                elseif l:chars[l:j] ==# '}' | let l:d -= 1
                    if l:d == 0 | return 1 | endif
                endif
                let l:j += 1
            endwhile
        endif
        let l:i += 1
    endwhile
    return 0
endfunction

" Split a line on the FIRST { that has a matching }.
" Returns [pre, inside, post]. Works even when line starts with }.
function! s:SplitOnOuterBraces(line)
    let l:chars = split(a:line, '\zs')
    let l:n = len(l:chars)
    let l:i = 0
    while l:i < l:n
        if l:chars[l:i] ==# '{'
            let l:d = 1 | let l:j = l:i + 1
            while l:j < l:n
                if     l:chars[l:j] ==# '{' | let l:d += 1
                elseif l:chars[l:j] ==# '}' | let l:d -= 1
                    if l:d == 0
                        let l:pre    = l:i == 0 ? '' : substitute(join(l:chars[0:l:i-1], ''), '\s*$', '', '')
                        let l:inside = join(l:chars[l:i+1:l:j-1], '')
                        let l:post   = trim(join(l:chars[l:j+1:], ''))
                        return [l:pre, l:inside, l:post]
                    endif
                endif
                let l:j += 1
            endwhile
        endif
        let l:i += 1
    endwhile
    return [a:line, '', '']
endfunction

" Split str on top-level commas.
function! s:SplitTopComma(str)
    let l:parts = [] | let l:cur = '' | let l:depth = 0
    for l:c in split(a:str, '\zs')
        if     l:c =~# '[({[]' | let l:depth += 1 | let l:cur .= l:c
        elseif l:c =~# '[)}\]]' | let l:depth -= 1 | let l:cur .= l:c
        elseif l:c ==# ',' && l:depth == 0
            call add(l:parts, l:cur) | let l:cur = ''
        else
            let l:cur .= l:c
        endif
    endfor
    if l:cur !=# '' | call add(l:parts, l:cur) | endif
    return l:parts
endfunction

" Split str on top-level semicolons.
function! s:SplitTopSemicolon(str)
    let l:parts = [] | let l:cur = '' | let l:depth = 0
    for l:c in split(a:str, '\zs')
        if     l:c =~# '[({[]' | let l:depth += 1 | let l:cur .= l:c
        elseif l:c =~# '[)}\]]' | let l:depth -= 1 | let l:cur .= l:c
        elseif l:c ==# ';' && l:depth == 0
            call add(l:parts, l:cur) | let l:cur = ''
        else
            let l:cur .= l:c
        endif
    endfor
    if l:cur !=# '' | call add(l:parts, l:cur) | endif
    return l:parts
endfunction

" Re-group comma-split items into struct field groups.
" ["range", "damage", "speed: f32"] -> ["range, damage, speed: f32"]
function! s:GroupStructFields(items)
    let l:has_colon = 0
    for l:item in a:items
        if s:HasSingleColon(trim(l:item)) | let l:has_colon = 1 | break | endif
    endfor
    if !l:has_colon
        return filter(map(copy(a:items), 'trim(v:val)'), 'v:val !~# "^\s*$"')
    endif
    let l:groups = [] | let l:acc = []
    for l:item in a:items
        let l:t = trim(l:item)
        if l:t ==# '' | continue | endif
        call add(l:acc, l:t)
        if s:HasSingleColon(l:t)
            call add(l:groups, join(l:acc, ', '))
            let l:acc = []
        endif
    endfor
    if !empty(l:acc) | call add(l:groups, join(l:acc, ', ')) | endif
    return l:groups
endfunction

" Return 1 if the header is a control-flow construct.
" Handles:
"   A) starts with CF keyword:  'if cond', 'else if cond', etc.
"   B) CF keyword after last top-level ';':  'case 1: stmt; if cond'
" NOTE: \> = end-of-word in Vimscript. \b = backspace, NOT word boundary.
" Strips leading whitespace and any leading } (for '} else {' lines).
function! s:IsControlFlow(header)
    let l:t = trim(substitute(trim(a:header), '^}\s*', '', ''))
    " Strip leading directive (e.g. '#partial' in '#partial switch')
    let l:t = trim(substitute(l:t, '^#\w\+\s\+', '', ''))
    if l:t =~# '^\(if\|else\|for\|when\|switch\)\>'
        return 1
    endif
    let l:chars = split(l:t, '\zs')
    let l:depth = 0 | let l:last_semi = -1
    for l:i in range(len(l:chars))
        let l:c = l:chars[l:i]
        if     l:c =~# '[({[]' | let l:depth += 1
        elseif l:c =~# '[)}\]]' | let l:depth -= 1
        elseif l:c ==# ';' && l:depth == 0 | let l:last_semi = l:i
        endif
    endfor
    if l:last_semi >= 0
        let l:after = trim(join(l:chars[l:last_semi + 1:], ''))
        if l:after =~# '^\(if\|else\|for\|when\|switch\)\>'
            return 1
        endif
    endif
    return 0
endfunction

function! s:IsProcLine(line)
    return a:line =~# '::\s*proc\>'
endfunction

" ============================================================
" <leader>f  -  Toggle single-line <-> multi-line { }
"
" Skips procedure definitions.
" Control-flow blocks (if/else/for/…): join with '; ', expand with ';'.
" All other blocks (struct/enum/literal): join with ', ', expand with ','.
" Aborts collapse when close line is '} else …' (chain continuation).
" ============================================================

function! s:FormatToggle()
    let l:lnum = line('.')
    let l:line = getline(l:lnum)

    if s:IsProcLine(l:line) | return | endif

    " Single-line: has a balanced { } pair and does not end with {
    if s:LineHasBraceBlock(l:line) && l:line !~# '{\s*$'
        call s:ExpandSingleLine(l:lnum)
        return
    endif

    " Opening line of a multi-line block
    if l:line =~# '{\s*$'
        let l:close = s:FindClose(l:lnum)
        if l:close > l:lnum
            call s:CollapseBlock(l:lnum, l:close)
            return
        endif
    endif

    " Inside a block — scan upward for opener
    let l:i = l:lnum - 1
    while l:i >= 1
        if getline(l:i) =~# '^\s*$' | break | endif
        if getline(l:i) =~# '{\s*$'
            if s:IsProcLine(getline(l:i)) | return | endif
            let l:close = s:FindClose(l:i)
            if l:close >= l:lnum
                call s:CollapseBlock(l:i, l:close)
                return
            endif
        endif
        let l:i -= 1
    endwhile
endfunction


" Align a list of body lines on their first single colon (not ::).
" Only applies when every non-empty line has a colon. Does nothing otherwise.
" Works purely on the list — no buffer interaction, no range extension.
function! s:AlignBodyColon(lines)
    if empty(a:lines) | return a:lines | endif

    " Detect block type from first non-empty line:
    "   dot-key  (.KEY = value)  -> align on =
    "   colon    (name : type)   -> align on :
    let l:first = ''
    for l:l in a:lines
        if trim(l:l) !=# '' | let l:first = trim(l:l) | break | endif
    endfor
    if l:first =~# '^\.[A-Za-z_]'
        return s:AlignBodyEquals(a:lines)
    endif

    " Colon alignment.
    " Parse each line into (indent, name, rest_after_colon).
    " 'name' is trimmed (no trailing spaces); output is  name + padding + ' : ' + rest.
    " This normalises any existing spacing around the colon.
    let l:parsed  = []
    let l:max_name = 0
    for l:l in a:lines
        let l:t = trim(l:l)
        if l:t ==# ''
            call add(l:parsed, {'t': 'blank', 'line': l:l}) | continue
        endif
        let l:ind   = matchstr(l:l, '^\s*')
        let l:chars = split(l:t, '\zs')
        let l:ci    = 0
        let l:found = 0
        while l:ci < len(l:chars)
            if l:chars[l:ci] ==# ':'
                if l:ci + 1 >= len(l:chars) || l:chars[l:ci + 1] !=# ':'
                    let l:name = trim(join(l:chars[0:l:ci > 0 ? l:ci-1 : 0], ''))
                    if l:ci == 0 | let l:name = '' | endif
                    let l:rest = trim(join(l:chars[l:ci+1:], ''))
                    if len(l:name) > l:max_name | let l:max_name = len(l:name) | endif
                    call add(l:parsed, {'t': 'field', 'ind': l:ind,
                        \ 'name': l:name, 'rest': l:rest})
                    let l:found = 1
                    break
                else
                    let l:ci += 1
                endif
            endif
            let l:ci += 1
        endwhile
        " No colon found — bail, return original lines unchanged
        if !l:found | return a:lines | endif
    endfor

    let l:new = []
    for l:p in l:parsed
        if l:p.t ==# 'blank'
            call add(l:new, l:p.line)
        else
            let l:pad = repeat(' ', l:max_name - len(l:p.name))
            call add(l:new, l:p.ind . l:p.name . l:pad . ' : ' . l:p.rest)
        endif
    endfor
    return l:new
endfunction

" Align .KEY = value lines on =.
function! s:AlignBodyEquals(lines)
    let l:parsed   = []
    let l:max_name = 0
    for l:l in a:lines
        let l:t = trim(l:l)
        if l:t ==# ''
            call add(l:parsed, {'t': 'blank', 'line': l:l}) | continue
        endif
        let l:ind = matchstr(l:l, '^\s*')
        let l:m   = matchlist(l:t, '^\(\S\+\)\s*=\s*\(.*\)$')
        if empty(l:m) | return a:lines | endif
        let l:name = l:m[1] | let l:val = l:m[2]
        if len(l:name) > l:max_name | let l:max_name = len(l:name) | endif
        call add(l:parsed, {'t': 'field', 'ind': l:ind, 'name': l:name, 'val': l:val})
    endfor
    let l:new = []
    for l:p in l:parsed
        if l:p.t ==# 'blank'
            call add(l:new, l:p.line)
        else
            let l:pad = repeat(' ', l:max_name - len(l:p.name))
            call add(l:new, l:p.ind . l:p.name . l:pad . ' = ' . l:p.val)
        endif
    endfor
    return l:new
endfunction

function! s:ExpandSingleLine(lnum)
    let l:line  = getline(a:lnum)
    let l:parts = s:SplitOnOuterBraces(l:line)
    let l:pre    = l:parts[0]
    let l:inside = l:parts[1]
    let l:post   = l:parts[2]
    let l:ind    = matchstr(l:pre, '^\s*')

    " If this line is a continuation of a multi-line condition, walk up
    " while the line above ends with || or && to find the CF keyword line.
    " Also use that line's indent (pure tabs) rather than the continuation
    " line's indent which may have extra spaces for visual alignment.
    let l:cf_check = l:pre
    let l:above    = a:lnum - 1
    while l:above >= 1
        let l:prev = trim(getline(l:above))
        if l:prev =~# '\(||\|&&\|,\)\s*$'
            let l:cf_check = l:prev
            let l:ind      = matchstr(getline(l:above), '^\s*')
            let l:above   -= 1
        else
            break
        endif
    endwhile
    let l:cf = s:IsControlFlow(l:cf_check)

    if l:cf
        let l:items = filter(map(s:SplitTopSemicolon(l:inside), 'trim(v:val)'), 'v:val !~# "^\s*$"')
    else
        let l:items = s:GroupStructFields(s:SplitTopComma(l:inside))
    endif

    let l:body = []
    for l:item in l:items
        let l:item = trim(substitute(l:item, '[,;]\s*$', '', ''))
        if l:item ==# '' | continue | endif
        call add(l:body, l:ind . "\t" . l:item . (l:cf ? '' : ','))
    endfor

    " Align body on colon for non-CF blocks (struct fields etc.)
    if !l:cf
        let l:body = s:AlignBodyColon(l:body)
    endif

    let l:close_line = l:ind . '}'
    if l:post !=# '' | let l:close_line .= ' ' . l:post | endif
    silent execute a:lnum . ',' . a:lnum . 'delete _'
    call append(a:lnum - 1, [l:pre . ' {'] + l:body + [l:close_line])
    call cursor(a:lnum, 1)
endfunction

function! s:CollapseBlock(open_ln, close_ln)
    let l:lines = getline(a:open_ln, a:close_ln)

    " Abort if close line continues with 'else'
    if l:lines[-1] =~# '^\s*}\s*else\>'
        return
    endif

    " Abort if any body line ends with { — a nested block is still expanded.
    " The user should collapse inner blocks first.
    for l:i in range(1, len(l:lines) - 2)
        if l:lines[l:i] =~# '{\s*$'
            return
        endif
    endfor

    let l:hdr = matchstr(l:lines[0], '^.\{-}\ze\s*{\s*$')
    " If the opener line is a continuation of a multi-line condition,
    " walk up while the line ABOVE ends with a continuation operator
    " (||, &&, ,) — that means the current line is mid-expression.
    let l:cf_check = l:hdr
    let l:above    = a:open_ln - 1
    while l:above >= 1
        let l:prev = trim(getline(l:above))
        if l:prev =~# '\(||\|&&\|,\)\s*$'
            let l:cf_check = l:prev
            let l:above   -= 1
        else
            break
        endif
    endwhile
    let l:cf  = s:IsControlFlow(l:cf_check)

    " Collect raw body lines, stripping comments and normalising whitespace
    let l:raw = []
    for l:i in range(1, len(l:lines) - 2)
        let l:v = trim(l:lines[l:i])
        if l:v =~# '^\s*$' | continue | endif
        let l:v = trim(substitute(l:v, '\s*\/\/.*$', '', ''))
        if l:v ==# '' | continue | endif
        call add(l:raw, substitute(l:v, '\s\+', ' ', 'g'))
    endfor

    " Merge continuation lines: if bracket depth > 0 after a line,
    " the next line is a continuation of the same statement.
    let l:stmts = []
    let l:buf   = '' | let l:depth = 0
    for l:v in l:raw
        if l:buf ==# ''
            let l:buf = l:v | let l:depth = s:BracketDepth(l:v)
        else
            let l:buf .= ' ' . l:v | let l:depth += s:BracketDepth(l:v)
        endif
        if l:depth <= 0
            call add(l:stmts, l:buf) | let l:buf = '' | let l:depth = 0
        endif
    endfor
    if l:buf !=# '' | call add(l:stmts, l:buf) | endif

    let l:items  = map(l:stmts, 'substitute(v:val, "[,;]\\s*$", "", "")')
    let l:sep    = l:cf ? '; ' : ', '
    let l:post   = trim(matchstr(l:lines[-1], '}\zs.*$'))
    let l:result = l:hdr . ' { ' . join(l:items, l:sep) . ' }'
    if l:post !=# '' | let l:result .= ' ' . l:post | endif

    silent execute a:open_ln . ',' . a:close_ln . 'delete _'
    call append(a:open_ln - 1, [l:result])
    call cursor(a:open_ln, 1)
endfunction

" ============================================================
" Key mappings
" ============================================================

nnoremap <silent> <buffer> <leader>n : call <SID>OdinCheck()<CR>
nnoremap <silent> <buffer> <leader>m : call <SID>OdinRun()<CR>
nnoremap <silent> <buffer> <leader>f : call <SID>FormatToggle()<CR>

nnoremap <buffer> <leader>p  A fmt.println("\n * 
nnoremap <buffer> <leader>sp /\c\v.* :: proc<Home><Right><Right><Right><Right>
nnoremap <buffer> <leader>ss /\c\v.* :: struct<Home><Right><Right><Right><Right>

inoremap jkp fmt.println("\n * 

command! -buffer OdinCheck  call s:OdinCheck()
command! -buffer OdinRun    call s:OdinRun()
command! -buffer OdinFormat call s:OdinFormatExternal()

let &cpo = s:cpo_save
unlet s:cpo_save
