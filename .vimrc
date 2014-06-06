execute pathogen#infect()

" Source the vimrc file after saving it
autocmd bufwritepost .vimrc source $MYVIMRC

set nocompatible

filetype on
filetype indent on
filetype plugin on

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window.
  set guifont=Lucida\ Console:h11
  au GUIEnter * simalt ~x
endif


syntax enable
set foldmethod=manual
set ignorecase
set hlsearch
set autoindent
set fileencoding=utf-8
set encoding=utf-8
set backspace=indent,eol,start
set ts=2 sts=2 sw=2 expandtab

set noeb vb t_vb= " disable belling sounds and visuals

" mapped '\y ' for copying into system clipboard
noremap <leader>y "+y 

" mapped '\p ' for pasting from system clipboard
noremap <leader>p "+p

" mapped \TAB for buffer next command
noremap <leader><tab> :bn<cr>
" mapped \SHIFT TAB for buffer prev command
noremap <leader><s-tab> :bp<cr>

" mapped CTRL-N for new empty buffer
noremap <c-N> :enew<cr>
inoremap <c-N> <esc>:enew<cr>

" mapped CRTL-W for closing current buffer
noremap <c-W> :bd<cr>
inoremap <c-W> <esc>:w<cr>:bd<cr>

" mapped crtl s for save
noremap  :w<cr>
inoremap  <esc>:w<cr>I

" mapped crtl shift s for save all
noremap <s-> :wa<cr>
inoremap <s-> <esc>:wa<cr>I

set smartcase
set gdefault
set incsearch
set showmatch
noh

" search hilight toggle
noremap <leader>sh :set hlsearch!<cr>

set winwidth=84
set winheight=5
set winminheight=5
set winheight=999

set nolist
set listchars=tab:°>,eol:¶,trail:°
set number
set noswapfile
set novisualbell
set nocursorline
set nowrap
set linebreak
"set background=dark
colo pablo
"hi PreProc ctermfg=white
"hi String ctermfg=cyan

" au FileType cs set omnifunc=syntaxcomplete#Complete
au FileType cs set foldmethod=marker 
au FileType cs set foldmarker={,} 
au FileType cs set foldtext=substitute(getline(v:foldstart),'{.*','{...}',) 
au FileType cs set foldlevelstart=5
au FileType sc set foldlevel=1

set virtualedit=onemore
set shiftwidth=2

set hidden

" autocmd vimenter * NERDTree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" try omnisharp ... it seems nice
