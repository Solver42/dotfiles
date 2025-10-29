syntax off
let mapleader = " "

if !isdirectory(expand('~/.vim/undodir'))
  call mkdir(expand('~/.vim/undodir'), 'p')
endif
set undodir=~/.vim/undodir
set undofile

" UNDOTREE
let g:undotree_buf = -1
let g:undotree_orig = -1
let g:undotree_data = []
function! s:Close()
    if bufexists(g:undotree_buf) | execute 'bwipeout ' . g:undotree_buf | endif
    let g:undotree_buf = -1
    if bufexists(g:undotree_orig) | execute 'buffer ' . g:undotree_orig | endif
endfunction
function! s:Highlight()
    if exists('w:ut_match') | call matchdelete(w:ut_match) | endif
    let w:ut_match = matchaddpos('Visual', [line('.')])
endfunction
function! s:Update()
    let l = line('.')
    if l < 1 || l > len(g:undotree_data) | return | endif
    call s:Highlight()
    let seq = g:undotree_data[l - 1].seq
    let win = winnr()
    execute bufwinnr(g:undotree_orig) . 'wincmd w'
    silent! execute seq == 0 ? 'earlier 999999' : 'undo ' . seq
    execute win . 'wincmd w'
endfunction
function! s:Select()
    call s:Update()
    call s:Close()
endfunction
function! s:Flatten(node, list, prefix)
    call add(a:list, {'seq': a:node.seq, 'line': a:prefix . strftime('%Y-%m-%d %H:%M:%S', a:node.time)})
endfunction
function! s:Open()
    let g:undotree_orig = bufnr('%')
    let tree = undotree()
    if empty(tree) | echo "No undo history" | return | endif
    botright vertical 40 new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap nonumber norelativenumber nocursorline nofoldenable winfixwidth
    silent! file __UNDOTREE__
    let g:undotree_buf = bufnr('%')
    let g:undotree_data = [{'seq': 0, 'line': 'initial'}]
    if has_key(tree, 'entries')
        for node in tree.entries | call s:Flatten(node, g:undotree_data, '') | endfor
    endif
    call setline(1, map(copy(g:undotree_data), 'v:val.line'))
    for i in range(len(g:undotree_data))
        if g:undotree_data[i].seq == tree.seq_cur
            execute 'normal! ' . (i + 1) . 'G'
            break
        endif
    endfor
    call s:Highlight()
    nnoremap <buffer> <silent> j j:call <SID>Update()<CR>
    nnoremap <buffer> <silent> k k:call <SID>Update()<CR>
    nnoremap <buffer> <silent> <CR> :call <SID>Select()<CR>
    nnoremap <buffer> <silent> q :call <SID>Close()<CR>
    call s:Update()
endfunction
function! UndotreeToggle()
    if bufexists(g:undotree_buf) && bufwinnr(g:undotree_buf) != -1
        call s:Close()
    else
        call s:Open()
    endif
endfunction
command! UndotreeToggle call UndotreeToggle()
nnoremap <leader>au :UndotreeToggle<CR>

set fillchars+=vert:\┃
set guitablabel=%t
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set mouse=a
set nobackup
set noswapfile
set autoread
set fileformat=unix
set encoding=UTF-8
set autoindent
set smartindent
set nowrap
set scrolloff=8
set showcmd
set noshowmode
set conceallevel=1
set shm=
set shm+=a
set shm+=c
set formatoptions-=cro
set noerrorbells visualbell t_vb=
set clipboard=unnamedplus
set incsearch
set hlsearch
set laststatus=0

let &t_SI = "\<esc>[6 q"
let &t_SR = "\<esc>[6 q"
let &t_EI = "\<esc>[2 q"

inoremap jkj <esc>
inoremap jkf <esc><cmd>w<cr>

nnoremap <leader>w <cmd>update<cr>
nnoremap <leader>l <cmd>bn<cr>
nnoremap <leader>h <cmd>bp<cr>
nnoremap <C-t> <cmd>tabnew<CR>
nnoremap L <cmd>tabn<CR>
nnoremap H <cmd>tabp<CR>
nnoremap sq ZQ
nnoremap <leader>q <cmd>bd<cr>
nnoremap ss <cmd>split<cr>
nnoremap sv <cmd>vsplit<cr>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sa <cmd>silent! vert ball<cr>
nnoremap so <cmd>only<cr>
nnoremap <C-L> <cmd>nohlsearch<CR><C-L>
nnoremap / /\c\v

xnoremap <leader>r y:%s/\V<C-r>=escape(@", '/\')<CR>//gI<Left><Left><Left>
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

"   TOGGLE
nnoremap - <cmd>Ex<CR>
autocmd FileType netrw nnoremap <buffer> - <cmd>b#<cr>
autocmd FileType netrw nmap <buffer> l <CR>

nnoremap <leader>an <cmd>set invnumber<cr>
nnoremap <leader>aw <cmd>set invwrap<cr>
nnoremap <leader>ac <cmd>set invcursorline<cr>

function! ToggleStatusLine()
        if &laststatus==0
                set laststatus=2
        else
                set laststatus=0
        endif
endfunction
nnoremap <leader>am <cmd>call ToggleStatusLine()<cr>

"   SURROUND
function! SurroundWordWithChar() abort
  let c = nr2char(getchar())
  return 'viwc' . c . "\<Esc>pa" . c . "\<Esc>"
endfunction

nnoremap <expr> mw SurroundWordWithChar()

function! SurroundWORDWithChar() abort
  let c = nr2char(getchar())
  return 'viWc' . c . "\<Esc>pa" . c . "\<Esc>"
endfunction

nnoremap <expr> mW SurroundWORDWithChar()

function! DeleteCharAroundCursor(char)
  let lnum = line('.')
  let col = col('.')
  let line = getline(lnum)
  " Search backward for char
  let left = col - 2
  while left >= 0 && line[left] != a:char
    let left -= 1
  endwhile
  " Search forward for char
  let right = col - 1
  while right < len(line) && line[right] != a:char
    let right += 1
  endwhile
  " If both sides found, delete them
  if left >= 0 && right < len(line)
    let newline = strpart(line, 0, left) . strpart(line, left + 1, right - left - 1) . strpart(line, right + 1)
    call setline(lnum, newline)
    call cursor(lnum, col - (col > right ? 1 : 0))
  else
    echo "Character not found on both sides"
  endif
endfunction

nnoremap <expr> mx ":call DeleteCharAroundCursor(nr2char(getchar()))<CR>"

function! ChangeCharAroundCursor(find_char, replace_char)
  let lnum = line('.')
  let col = col('.')
  let line = getline(lnum)

  " Search backward for find_char
  let left = col - 2
  while left >= 0 && line[left] != a:find_char
    let left -= 1
  endwhile

  " Search forward for find_char
  let right = col - 1
  while right < len(line) && line[right] != a:find_char
    let right += 1
  endwhile

  " Only proceed if both found
  if left >= 0 && right < len(line)
    let newline = strpart(line, 0, left) . a:replace_char . strpart(line, left + 1, right - left - 1) . a:replace_char . line[right + 1:]
    call setline(lnum, newline)

    " Optional: put cursor back near where it was
    call cursor(lnum, min([col, len(newline)]))
  else
    echo "Could not find both surrounding characters"
  endif
endfunction

nnoremap <expr> mc ":call ChangeCharAroundCursor(nr2char(getchar()), nr2char(getchar()))<CR>"

hi Normal ctermfg=46
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
hi Visual ctermfg=16 ctermbg=46
hi StatusLine ctermfg=16 ctermbg=46
hi StatusLineNC ctermfg=46 ctermbg=16
hi VertSplit ctermbg=NONE ctermfg=46 cterm=NONE
hi CursorLine ctermbg=46 ctermfg=16 cterm=NONE

set statusline=
set statusline+=%#WildMenu#\ %{mode()}\  " Mode with custom highlight
set statusline+=%#Normal#                " Reset highlight for filename
set statusline+=\ %f\ %=
set statusline+=%#WildMenu#
set statusline+=\ %l:%c\ 

set tabline=%!MyTabLine()

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    let tabnr = i + 1
    let winnr = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let name = bufname(bufnr)
    let short_name = fnamemodify(name, ':t')

    if tabnr == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    let s .= '%' . tabnr . 'T ' . short_name . ' '
  endfor
  let s .= '%#TabLineFill#%T'
  return s
  s .= fnamemodify(name, ':t')
  return 
endfunction

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_keepdir = 0

" Close after opening a file (which gets opened in another window):
let g:netrw_fastbrowse = 0
autocmd FileType netrw setl bufhidden=wipe
function! CloseNetrw() abort
  for bufn in range(1, bufnr('$'))
    if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
      silent! execute 'bwipeout ' . bufn
      if getline(2) =~# '^" Netrw '
        silent! bwipeout
      endif
      return
    endif
  endfor
endfunction
augroup closeOnOpen
  autocmd!
  autocmd BufWinEnter * if getbufvar(winbufnr(winnr()), "&filetype") != "netrw"|call CloseNetrw()|endif
aug END

autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
let g:fzf_layout = { 'window': { 'width': 1, 'height': 1 } }

let g:fzf_preview_window = ['right:50%', 'ctrl-/']
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {
    \   'options': ['--preview', 'bat --style=plain --color=never {}']
    \ }, <bang>0)


command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    \   {'options': ['--delimiter', ':', '--preview', 'bat --style=plain --color=never --highlight-line {2} {1}', '--preview-window', '+{2}-/2']}, <bang>0)

nnoremap <leader>j <cmd>Files<CR>
nnoremap <leader>k <cmd>Rg<CR>
nnoremap <leader>b <cmd>Buffers<CR>
