" Vundle Section Begin
set nocompatible    " be iMproved, required
filetype off        " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" plugins
Plugin 'moll/vim-node'
Plugin 'fatih/vim-go'
Plugin 'Shutnik/jshint2.vim'
Plugin 'dracula/vim'


" All of your plugins must be added before end
call vundle#end()           " required
filetype plugin indent on   " required

" Vundle Section End

set autoindent
set smartindent
set smarttab

set number
set ruler
set laststatus=2
set cursorline

" set search
set ignorecase
set incsearch
set hlsearch

" set mouse
set mouse=a

" share system clipboard
set clipboard=unnamed

" set highlight
syntax on

" set color themes
" colorscheme molokai
" set background=dark

" disable italic, need to set before loading dracula color scheme
" let g:dracula_italic = 0
color dracula

" set the background transparent
hi Normal guibg=NONE ctermbg=NONE

" set tab width
set tabstop=2
set shiftwidth=2
set expandtab

" set text width
" set textwidth=120
set colorcolumn=120

" make backspace work like most other apps
set backspace=2

" italic setting within tmux
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab 
autocmd FileType go setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType java setlocal tabstop=4 shiftwidth=4 expandtab

autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab 
autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab

" gradle syntax highlight
au BufNewFile,BufRead *.gradle setf groovy

" supertab
" let g:SuperTabMappingForward = '<C-Tab>'

" latex
autocmd FileType tex setlocal makeprg=pdflatex\ --shell-escape\ '%'
map <F5> :w<CR> :!pdflatex %<<CR>

" Jshint inside vim
map <F2> :JSHint<CR>
