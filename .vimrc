" PERFORMANCE SETTINGS
syntax off
set ttyfast
set lazyredraw

let mapleader = " "

" FILE SETTINGS
set undofile
set nobackup
set noswapfile
set autoread
set hidden
set fileformat=unix
set encoding=UTF-8

if !isdirectory(expand('~/.vim/undodir'))
  call mkdir(expand('~/.vim/undodir'), 'p')
endif
set undodir=~/.vim/undodir

filetype plugin indent on

" UI SETTINGS
set fillchars+=vert:\┃
set guitablabel=%t
set mouse=a
set showcmd
set noshowmode
set conceallevel=1
set shortmess=ltToOCF
set formatoptions-=cro
set noerrorbells
set visualbell
set t_vb=
set nowrap
set scrolloff=8
set sidescrolloff=5
set signcolumn=yes
set laststatus=0
set updatetime=100
set timeoutlen=5000
set ttimeoutlen=10

" LINE NUMBERS (OFF BY DEFAULT)
set nonumber
set norelativenumber

" SEARCH SETTINGS
set incsearch
set hlsearch
set ignorecase
set smartcase

" INDENTATION
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set smartindent

" COMPLETION & CLIPBOARD
set clipboard=unnamedplus
set complete-=t
" set completeopt=menuone,noselect
set wildmenu
set wildmode=longest:full,full

" CURSOR SHAPE
if exists('&t_SI')
  let &t_SI = "\<esc>[6 q"
  let &t_SR = "\<esc>[6 q"
  let &t_EI = "\<esc>[2 q"
endif

" COLOR SCHEME
hi Normal ctermfg=46
hi SignColumn ctermbg=NONE
hi LineNr ctermfg=46
hi CursorLineNr ctermfg=16 ctermbg=46 cterm=NONE
hi TabLine ctermbg=NONE ctermfg=46 cterm=NONE
hi TabLineFill ctermfg=16 cterm=NONE
hi TabLineSel ctermfg=16 ctermbg=46 cterm=NONE
hi EndOfBuffer ctermbg=NONE ctermfg=NONE
hi IncSearch ctermbg=16 ctermfg=46
hi Search ctermbg=226 ctermfg=16
hi CurSearch ctermbg=46 ctermfg=16
hi WildMenu ctermfg=16 ctermbg=46
hi Visual ctermfg=16 ctermbg=28
hi StatusLine ctermfg=16 ctermbg=46
hi StatusLineNC ctermfg=46 ctermbg=16
hi VertSplit ctermbg=NONE ctermfg=46 cterm=NONE
hi CursorLine ctermbg=46 ctermfg=16 cterm=NONE
hi Pmenu ctermfg=28 ctermbg=NONE
hi PmenuSel ctermfg=16 ctermbg=46
hi PmenuSbar ctermfg=46 ctermbg=NONE
hi PmenuThumb ctermfg=16 ctermbg=46
hi HLCurrentWord ctermfg=16 ctermbg=46

" INSERT MODE MAPPINGS
inoremap jkj <esc>
inoremap jkf <esc><cmd>update<cr>

" NORMAL MODE MAPPINGS

" FILE OPERATIONS
nnoremap <leader>w <cmd>update<cr>
nnoremap sq ZQ

" BUFFER NAVIGATION
nnoremap <leader>l <cmd>bn<cr>
nnoremap <leader>h <cmd>bp<cr>
nnoremap <leader>bd <cmd>%bd\|e#\|bd#<cr>

" TAB NAVIGATION
nnoremap <C-t> <cmd>tabnew<CR>
nnoremap L <cmd>tabn<CR>
nnoremap H <cmd>tabp<CR>

" WINDOW MANAGEMENT
nnoremap ss <cmd>split<cr>
nnoremap sv <cmd>vsplit<cr>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap s= <C-w>=
nnoremap sa <cmd>silent! vert ball<cr>
nnoremap so <cmd>only<cr>

" SEARCH & REPLACE
nnoremap <C-L> <cmd>nohlsearch<CR><C-L>
nnoremap / /\c\v
nnoremap * *N

" QUICK SHELL COMMAND
nnoremap Q !!sh<cr>

" FILE EXPLORER
nnoremap - <cmd>Ex<CR>

" TOGGLES
nnoremap <leader>an <cmd>set invnumber<cr>
nnoremap <leader>ar <cmd>set invrelativenumber<cr>
nnoremap <leader>aw <cmd>set invwrap<cr>
nnoremap <leader>ac <cmd>set invcursorline<cr>
nnoremap <leader>as :set signcolumn=<C-R>=&signcolumn == 'yes' ? 'no' : 'yes'<CR><CR>
nnoremap <leader>am <cmd>call ToggleStatusLine()<cr>
nnoremap <leader>ah <cmd>call <SID>ToggleHighlightWord()<cr>

" VISUAL MODE MAPPINGS
xnoremap <leader>r y:%s/\V<C-r>=escape(@", '/\')<CR>//gI<Left><Left><Left>
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

" Maintain visual mode after indent
xnoremap < <gv
xnoremap > >gv

" SURROUND FUNCTIONS
function! SurroundWordWithChar() abort
  let c = nr2char(getchar())
  let pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
  let opening = index(values(pairs), c) >= 0 ? keys(pairs)[index(values(pairs), c)] : c
  let closing = get(pairs, opening, c)
  return 'viwc' . opening . "\<Esc>pa" . closing . "\<Esc>"
endfunction

function! SurroundBigWordWithChar() abort
  let c = nr2char(getchar())
  let pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
  let opening = index(values(pairs), c) >= 0 ? keys(pairs)[index(values(pairs), c)] : c
  let closing = get(pairs, opening, c)
  return 'viWc' . opening . "\<Esc>pa" . closing . "\<Esc>"
endfunction

function! DeleteCharAroundCursor() abort
  let c = nr2char(getchar())
  let pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
  let opening = index(values(pairs), c) >= 0 ? keys(pairs)[index(values(pairs), c)] : c
  let closing = get(pairs, opening, c)
  if opening == closing
    " For symmetric characters like quotes
    call search('\V' . escape(c, '\'), 'bW')
    normal! x
    call search('\V' . escape(c, '\'), 'W')
    normal! x
  else
    " For paired characters
    call searchpair('\V' . escape(opening, '\'), '', '\V' . escape(closing, '\'), 'bW')
    normal! x
    call searchpair('\V' . escape(opening, '\'), '', '\V' . escape(closing, '\'), 'W')
    normal! x
  endif
  return ''
endfunction

" function! ChangeCharAroundCursor(find_char, replace_char) abort
  " let lnum = line('.')
  " let col = col('.')
  " let line = getline(lnum)
  " let left = col - 2
  " while left >= 0 && line[left] != a:find_char | let left -= 1 | endwhile
  " let right = col - 1
  " while right < len(line) && line[right] != a:find_char | let right += 1 | endwhile
  " if left >= 0 && right < len(line)
    " let newline = strpart(line, 0, left) . a:replace_char . strpart(line, left + 1, right - left - 1) . a:replace_char . line[right + 1:]
    " call setline(lnum, newline)
    " call cursor(lnum, min([col, len(newline)]))
  " else
    " echo "Could not find both surrounding characters"
  " endif
" endfunction

function! ChangeCharAroundCursor() abort
  let old_c = nr2char(getchar())
  let new_c = nr2char(getchar())
  let pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
  let old_opening = index(values(pairs), old_c) >= 0 ? keys(pairs)[index(values(pairs), old_c)] : old_c
  let old_closing = get(pairs, old_opening, old_c)
  let new_opening = index(values(pairs), new_c) >= 0 ? keys(pairs)[index(values(pairs), new_c)] : new_c
  let new_closing = get(pairs, new_opening, new_c)
  if old_opening == old_closing
    call search('\V' . escape(old_c, '\'), 'bW')
    execute 'normal! r' . new_opening
    call search('\V' . escape(old_c, '\'), 'W')
    execute 'normal! r' . new_closing
  else
    call searchpair('\V' . escape(old_opening, '\'), '', '\V' . escape(old_closing, '\'), 'bW')
    execute 'normal! r' . new_opening
    call searchpair('\V' . escape(old_opening, '\'), '', '\V' . escape(old_closing, '\'), 'W')
    execute 'normal! r' . new_closing
  endif
  return ''
endfunction

nnoremap <expr> mw SurroundWordWithChar()
nnoremap <expr> mW SurroundBigWordWithChar()
nnoremap <expr> mx ":call DeleteCharAroundCursor()<CR>"
nnoremap <expr> mc ":call ChangeCharAroundCursor()<CR>"

" UNDOTREE
let g:undotree_buf = -1
let g:undotree_orig = -1
let g:undotree_data = []

function! s:UndotreeClose() abort
    if bufexists(g:undotree_buf) | execute 'bwipeout ' . g:undotree_buf | endif
    let g:undotree_buf = -1
    if bufexists(g:undotree_orig) | execute 'buffer ' . g:undotree_orig | endif
endfunction

function! s:UndotreeHighlight() abort
    if exists('w:ut_match') | call matchdelete(w:ut_match) | endif
    let w:ut_match = matchaddpos('Visual', [line('.')])
endfunction

function! s:UndotreeUpdate() abort
    let l = line('.')
    if l < 1 || l > len(g:undotree_data) | return | endif
    call s:UndotreeHighlight()
    let seq = g:undotree_data[l - 1].seq
    let win = winnr()
    execute bufwinnr(g:undotree_orig) . 'wincmd w'
    silent! execute seq == 0 ? 'earlier 999999' : 'undo ' . seq
    execute win . 'wincmd w'
endfunction

function! s:UndotreeSelect() abort
    call s:UndotreeUpdate()
    call s:UndotreeClose()
endfunction

function! s:UndotreeFlatten(node, list, prefix) abort
    call add(a:list, {'seq': a:node.seq, 'line': a:prefix . strftime('%Y-%m-%d %H:%M:%S', a:node.time)})
endfunction

function! s:UndotreeOpen() abort
    let g:undotree_orig = bufnr('%')
    let tree = undotree()
    if empty(tree) | echo "No undo history" | return | endif
    
    botright vertical 40 new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap 
    setlocal nonumber norelativenumber nocursorline nofoldenable winfixwidth
    silent! file __UNDOTREE__
    let g:undotree_buf = bufnr('%')
    
    let g:undotree_data = [{'seq': 0, 'line': 'initial'}]
    if has_key(tree, 'entries')
        for node in tree.entries | call s:UndotreeFlatten(node, g:undotree_data, '') | endfor
    endif
    
    call setline(1, map(copy(g:undotree_data), 'v:val.line'))
    
    for i in range(len(g:undotree_data))
        if g:undotree_data[i].seq == tree.seq_cur
            execute 'normal! ' . (i + 1) . 'G'
            break
        endif
    endfor
    
    call s:UndotreeHighlight()
    
    nnoremap <buffer> <silent> j j:call <SID>UndotreeUpdate()<CR>
    nnoremap <buffer> <silent> k k:call <SID>UndotreeUpdate()<CR>
    nnoremap <buffer> <silent> <CR> :call <SID>UndotreeSelect()<CR>
    nnoremap <buffer> <silent> q :call <SID>UndotreeClose()<CR>
    
    call s:UndotreeUpdate()
endfunction

function! UndotreeToggle() abort
    if bufexists(g:undotree_buf) && bufwinnr(g:undotree_buf) != -1
        call s:UndotreeClose()
    else
        call s:UndotreeOpen()
    endif
endfunction

command! UndotreeToggle call UndotreeToggle()
nnoremap <leader>au :UndotreeToggle<CR>

" STATUSLINE
set statusline=
set statusline+=%#WildMenu#\ %{mode()}\  
set statusline+=%#Normal#                
set statusline+=\ %f\ %m%r
set statusline+=%=
set statusline+=%#WildMenu#
set statusline+=\ %l:%c\ 

function! ToggleStatusLine() abort
    let &laststatus = &laststatus == 0 ? 2 : 0
endfunction

" HIGHLIGHT WORD UNDER CURSOR
let g:hiword = 1
let s:lastWord = ""

function! s:HighlightWord(word) abort
    let l:pattern = '\<' . escape(a:word, '\.^$*\/[]\"~') . '\>'
    execute 'match HLCurrentWord /\V' . l:pattern . '/'
endfunction

function! s:HW_Cursor_Moved() abort
    if !g:hiword || !&modifiable | return | endif
    let l:word = expand('<cword>')
    if l:word == s:lastWord | return | endif
    let s:lastWord = l:word
    
    if empty(l:word)
        match none
    else
        call s:HighlightWord(l:word)
    endif
endfunction

function! s:ToggleHighlightWord() abort
    let g:hiword = !g:hiword
    echo 'Word highlighting ' . (g:hiword ? 'enabled' : 'disabled')
    if !g:hiword
        match none
        let s:lastWord = ""
    endif
endfunction

augroup HighlightWordUnderCursor
    autocmd!
    autocmd CursorMoved,CursorMovedI * call s:HW_Cursor_Moved()
augroup END

" COMMENT TOGGLE
function! ToggleComment(comment_string) range abort
    let l:comment_pattern = '^' . escape(a:comment_string, '/*') . '\s\?'
    let l:all_commented = 1
    
    for l:lnum in range(a:firstline, a:lastline)
        let l:content = substitute(getline(l:lnum), '^\s*', '', '')
        if !empty(l:content) && l:content !~# l:comment_pattern
            let l:all_commented = 0
            break
        endif
    endfor
    
    for l:lnum in range(a:firstline, a:lastline)
        let l:line = getline(l:lnum)
        let l:indent = matchstr(l:line, '^\s*')
        let l:content = substitute(l:line, '^\s*', '', '')
        if empty(l:content) | continue | endif
        
        let l:new_content = l:all_commented 
            \ ? substitute(l:content, l:comment_pattern, '', '')
            \ : a:comment_string . ' ' . l:content
        call setline(l:lnum, l:indent . l:new_content)
    endfor
endfunction

" NETRW CONFIGURATION
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_keepdir = 0
let g:netrw_fastbrowse = 0
let g:netrw_winsize = 25

function! CloseNetrw() abort
  for bufn in range(1, bufnr('$'))
    if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
      silent! execute 'bwipeout ' . bufn
      return
    endif
  endfor
endfunction

augroup NetrwConfig
    autocmd!
    autocmd FileType netrw nnoremap <buffer> - <cmd>b#<cr>
    autocmd FileType netrw nmap <buffer> l <CR>
    autocmd FileType netrw setlocal bufhidden=wipe
    autocmd BufWinEnter * if getbufvar(winbufnr(winnr()), "&filetype") != "netrw" | call CloseNetrw() | endif
augroup END

" RESTORE CURSOR POSITION
augroup RestoreCursor
    autocmd!
    autocmd BufReadPost * 
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
        \ |   exe "normal! g`\"" 
        \ | endif
augroup END

" FZF CONFIGURATION
if executable('fzf')
    let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    let g:fzf_layout = { 'window': { 'width': 1, 'height': 1 } }
    let g:fzf_preview_window = ['right:50%', 'ctrl-/']

    command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(<q-args>, {
        \   'options': ['--preview', 'bat --style=plain --color=never {}'],
        \   'source': 'rg --files --no-ignore'
        \ }, <bang>0)

    command! -bang -nargs=? -complete=dir FilesHidden
        \ call fzf#vim#files(<q-args>, {
        \   'options': ['--preview', 'bat --style=plain --color=never {}'],
        \   'source': 'rg --files --no-ignore --hidden'
        \ }, <bang>0)

    command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case --no-ignore -- '.shellescape(<q-args>), 1,
        \   {'options': ['--delimiter', ':', '--preview', 'bat --style=plain --color=never --highlight-line {2} {1}', '--preview-window', '+{2}-/2']}, <bang>0)

    command! -bang -nargs=* RgHidden
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case --no-ignore --hidden -- '.shellescape(<q-args>), 1,
        \   {'options': ['--delimiter', ':', '--preview', 'bat --style=plain --color=never --highlight-line {2} {1}', '--preview-window', '+{2}-/2']}, <bang>0)

    command! -bang Buffers
        \ call fzf#vim#buffers({
        \   'options': ['--preview', 'echo {} | awk "{print \$NF}" | xargs bat --style=plain --color=never']
        \ }, <bang>0)

    nnoremap <leader>j <cmd>Files<CR>
    nnoremap <leader>J <cmd>FilesHidden<CR>
    nnoremap <leader>k <cmd>Rg<CR>
    nnoremap <leader>K <cmd>RgHidden<CR>
    nnoremap <leader>b <cmd>Buffers<CR>
    nnoremap <leader>B <cmd>Buffers<CR>
endif
