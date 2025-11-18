nnoremap <buffer> <C-k> :call ToggleComment('//')<CR>
vnoremap <buffer> <C-k> :call ToggleComment('//')<CR>

setlocal tabstop=4
setlocal shiftwidth=4
setlocal noexpandtab
setlocal smarttab
setlocal autoindent
setlocal smartindent

" Prevent the ftplugin to run multiple times
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" Find project root by looking for main.odin
function! s:FindProjectRoot()
  let l:current_dir = expand('%:p:h')
  let l:max_depth = 10
  let l:depth = 0
  
  while l:depth < l:max_depth
    " Check if main.odin exists in current directory
    if filereadable(l:current_dir . '/main.odin')
      return l:current_dir
    endif
    
    " Go up one directory
    let l:parent = fnamemodify(l:current_dir, ':h')
    
    " Stop if we've reached the root
    if l:parent == l:current_dir
      break
    endif
    
    let l:current_dir = l:parent
    let l:depth += 1
  endwhile
  
  " If no main.odin found, use current file's directory
  return expand('%:p:h')
endfunction

" Check command - validate code without building
function! s:OdinCheck()
  if &modified
    silent write
  endif
  
  let l:dir = s:FindProjectRoot()
  let l:output = system('cd ' . shellescape(l:dir) . ' && odin check . 2>&1')
  
  redraw!
  
  " Check for first error: filepath(line:column) message
  let l:match = matchlist(l:output, '\([^(]\+\)(\(\d\+\):\(\d\+\))\s*\([^\n]*\)')
  
  if !empty(l:match)
    " Found an error - jump to it
    execute 'edit' l:match[1]
    call cursor(str2nr(l:match[2]), str2nr(l:match[3]))
    redraw!
    
    execute 'highlight OdinBuildError ctermfg=9 ctermbg=NONE'
    echohl OdinBuildError
    echon l:match[4]
    echohl None
  else
    " Check successful
    execute 'highlight OdinBuildSuccess ctermfg=46 ctermbg=NONE'
    echohl OdinBuildSuccess
    echon "odin check successful"
    echohl None
  endif
endfunction

" Run command - compile and run without creating executable
function! s:OdinRun()
  if &modified
    silent write
  endif
  
  let l:dir = s:FindProjectRoot()
  
  " First check for errors
  let l:check_output = system('cd ' . shellescape(l:dir) . ' && odin check . 2>&1')
  let l:match = matchlist(l:check_output, '\([^(]\+\)(\(\d\+\):\(\d\+\))\s*\([^\n]*\)')
  
  if !empty(l:match)
    " Found an error - jump to it
    redraw!
    execute 'edit' l:match[1]
    call cursor(str2nr(l:match[2]), str2nr(l:match[3]))
    redraw!
    
    execute 'highlight OdinBuildError ctermfg=9 ctermbg=NONE'
    echohl OdinBuildError
    echon l:match[4]
    echohl None
  else
    " No errors - run the program
    execute '!cd ' . shellescape(l:dir) . ' && odin run .'
  endif
endfunction

" Format with odinfmt
function! s:OdinFormat()
  if &modified
    silent write
  endif
  
  let l:odinfmt = expand('~/dev/tools/ols/odinfmt')
  if !executable(l:odinfmt)
    echon "odinfmt not found"
    return
  endif
  
  let l:file = expand('%:p')
  let l:output = system(l:odinfmt . ' -stdin < ' . shellescape(l:file) . ' 2>&1')
  let l:exit_code = v:shell_error
  
  redraw!
  
  " Check for error: <stdin>(line:column): message
  if l:output =~ '<stdin>(\d\+:\d\+):'
    let l:match = matchlist(l:output, '<stdin>(\(\d\+\):\(\d\+\)):\s*\([^\n]*\)')
    if !empty(l:match)
      " Found an error - just show it, don't format
      call cursor(str2nr(l:match[1]), str2nr(l:match[2]))
      redraw!
      
      execute 'highlight OdinBuildError ctermfg=9 ctermbg=NONE'
      echohl OdinBuildError
      echon "Cannot format: " . l:match[3]
      echohl None
    endif
  elseif l:exit_code == 0 && len(l:output) > 0
    " Format successful - replace buffer content
    let l:save_view = winsaveview()
    silent %delete _
    call setline(1, split(l:output, '\n'))
    call winrestview(l:save_view)
    silent write
    
    execute 'highlight OdinBuildSuccess ctermfg=46 ctermbg=NONE'
    echohl OdinBuildSuccess
    echon "odin file formatted"
    echohl None
  else
    execute 'highlight OdinBuildError ctermfg=9 ctermbg=NONE'
    echohl OdinBuildError
    echon "Format failed"
    echohl None
  endif
endfunction

" Key mappings
nnoremap <buffer> <leader>n :call <SID>OdinCheck()<CR>
nnoremap <buffer> <leader>m :call <SID>OdinRun()<CR>
nnoremap <buffer> <leader>f :call <SID>OdinFormat()<CR>

" Commands
command! -buffer OdinCheck call s:OdinCheck()
command! -buffer OdinRun call s:OdinRun()
command! -buffer OdinFormat call s:OdinFormat()

let &cpo = s:cpo_save
unlet s:cpo_save
