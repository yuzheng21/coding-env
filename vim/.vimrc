set nocompatible

" vim-plug
call plug#begin('~/.vim/plugged')
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

filetype plugin indent on

" General
set autoindent
set smartindent
set smarttab
set hidden
set wildmenu
set scrolloff=5
set noerrorbells
set splitright
set splitbelow

" UI
set number
set ruler
set laststatus=2
set cursorline

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Mouse & clipboard
set mouse=a
set clipboard=unnamed

" Syntax highlighting
syntax on

" Theme
color dracula
hi Normal guibg=NONE ctermbg=NONE

" Indentation
set tabstop=2
set shiftwidth=2
set expandtab
set colorcolumn=120
set backspace=2

" Per-filetype indentation
autocmd FileType python,go,java setlocal tabstop=4 shiftwidth=4

" Map Shift-Tab to un-indent in insert mode
inoremap <S-Tab> <C-d>

" True color support
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
if has('termguicolors')
  set termguicolors
endif

" Key mappings
nnoremap <leader>h :nohlsearch<CR>
nnoremap ; :

" LaTeX
autocmd FileType tex setlocal makeprg=pdflatex\ --shell-escape\ '%'
map <F5> :w<CR> :!pdflatex %<<CR>

" Gradle
au BufNewFile,BufRead *.gradle setf groovy
