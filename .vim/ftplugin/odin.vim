nnoremap <buffer> <C-k> :call ToggleComment('//')<CR>
vnoremap <buffer> <C-k> :call ToggleComment('//')<CR>

let s:odinfmt = expand('~/dev/tools/ols/odinfmt')
if executable(s:odinfmt)
    let &l:equalprg = s:odinfmt . ' -stdin'
endif

setlocal tabstop=4
setlocal shiftwidth=4
setlocal noexpandtab
setlocal smarttab
setlocal autoindent
setlocal smartindent
