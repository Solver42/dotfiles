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

nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>l <cmd>bnext<cr>
nnoremap <leader>h <cmd>bprev<cr>
nnoremap <C-t> <cmd>tabnew<CR>
nnoremap L <cmd>tabnext<CR>
nnoremap H <cmd>tabprev<CR>
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
nnoremap <A-n> <cmd>set invnumber<cr>
nnoremap <C-L> <cmd>nohlsearch<CR><C-L>
nnoremap - <cmd>Explore<CR>
nnoremap / /\c\v

function! ToggleStatusLine()
        if &laststatus==0
                set laststatus=2
        else
                set laststatus=0
        endif
endfunction
nnoremap <A-m> <cmd>call ToggleStatusLine()<cr>

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
