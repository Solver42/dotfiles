syntax off

set guitablabel=%t
set tabstop=4
set mouse=a
set nobackup
set noswapfile
set undodir=~/.vim/undodir
set undofile
set autoread
set fileformat=unix
set encoding=UTF-8
set autoindent
set smartindent
set smarttab
set expandtab
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

let mapleader = " "
let &t_SI = "\<esc>[6 q"
let &t_SR = "\<esc>[6 q"
let &t_EI = "\<esc>[2 q"

inoremap jkj <esc>
inoremap jkf <esc><cmd>w<cr>

nnoremap <leader>w <cmd>w<cr>
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
vnoremap <leader>r "hy :%s/\<<C-r>h\>//gI<left><left><left>

"   TOGGLE

nnoremap - <cmd>Ex<CR>
autocmd FileType netrw nnoremap <buffer> - <cmd>bd<cr>
autocmd FileType netrw nmap <buffer> l <CR>

nnoremap <A-n> <cmd>set invnumber<cr>

function! ToggleStatusLine()
        if &laststatus==0
                set laststatus=2
        else
                set laststatus=0
        endif
endfunction
nnoremap <A-m> <cmd>call ToggleStatusLine()<cr>

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
hi TabLine ctermbg=16 ctermfg=46 cterm=NONE
hi TabLineFill ctermfg=16 cterm=NONE
hi TabLineSel ctermfg=16 ctermbg=46 cterm=NONE
hi EndOfBuffer ctermbg=16 ctermfg=16
hi IncSearch ctermbg=16 ctermfg=46
hi Search ctermbg=226 ctermfg=16
hi CurSearch ctermbg=46 ctermfg=16
hi WildMenu ctermfg=16 ctermbg=46
hi Visual ctermfg=16 ctermbg=46
hi StatusLine ctermfg=16 ctermbg=46
hi StatusLineNC ctermfg=46 ctermbg=16
hi VertSplit ctermbg=46 ctermfg=16
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

au BufEnter *.txt  only

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
