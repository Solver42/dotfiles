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

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:OdinBuild()
  if &modified
    silent write
  endif
  
  let l:dir = expand('%:p:h')
  let l:output = system('cd ' . shellescape(l:dir) . ' && odin build . 2>&1')
  let l:lines = split(l:output, '\n')
  let l:qflist = []
  
  for line in l:lines
    let l:match = matchlist(line, '\([^(]\+\)(\(\d\+\):\(\d\+\))\s*\(.*\)')
    if !empty(l:match)
      call add(l:qflist, {
        \ 'filename': l:match[1],
        \ 'lnum': str2nr(l:match[2]),
        \ 'col': str2nr(l:match[3]),
        \ 'text': l:match[4]
        \ })
    endif
  endfor
  call setqflist(l:qflist, 'r')
  redraw!
  cclose
  if len(l:qflist) > 0
    let l:first_error = l:qflist[0]
    execute 'edit' l:first_error.filename
    call cursor(l:first_error.lnum, l:first_error.col)
    redraw!
    execute 'highlight OdinBuildError ctermfg=16 ctermbg=196'
    echohl OdinBuildError
    echo l:first_error.text
    echohl None
  else
    echohl None
    execute 'highlight OdinBuildSuccess ctermfg=16 ctermbg=46'
    echohl OdinBuildSuccess
    echo "Build successful"
    echohl None
  endif
endfunction

function! s:OdinBuildRun()
  call s:OdinBuild()
  if len(getqflist()) == 0
    let l:dir = expand('%:p:h')
    let l:exec_name = fnamemodify(l:dir, ':t')
    if filereadable(l:dir . '/' . l:exec_name)
      execute '!./' . l:exec_name
    elseif filereadable(l:dir . '/game')
      execute '!./game'
    else
      echo "Executable not found. Build succeeded but couldn't find binary."
    endif
  endif
endfunction

setlocal makeprg=odin\ build\ .\ 2>&1
setlocal errorformat=%f(%l:%c)\ %m,%f(%l:%c)%m
nnoremap <buffer> <F5> :call <SID>OdinBuild()<CR>
nnoremap <buffer> <F6> :call <SID>OdinBuildRun()<CR>

command! -buffer OdinBuild call s:OdinBuild()
command! -buffer OdinRun call s:OdinBuildRun()

let &cpo = s:cpo_save
unlet s:cpo_save
