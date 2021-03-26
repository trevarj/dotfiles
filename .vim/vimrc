" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Tpope
Plug 'tpope/vim-sensible' 
Plug 'tpope/vim-commentary' 
Plug 'tpope/vim-fugitive' 

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Theme/UI
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'ryanoasis/vim-devicons'

" Language support
Plug 'rust-lang/rust.vim'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'cespare/vim-toml'

" Initialize plugin system
call plug#end()

" Theme
colorscheme gruvbox

source $VIMRUNTIME/defaults.vim
" Create symlink here
" source ~/.vim/plugin/coc-conf.vim

" KEY BINDINGS
map <c-c> <esc>

nmap <C-p> :GFiles<CR>
nmap <C-P> :Files<CR>
nmap <leader>; :Buffers<CR>
nmap <leader>f :Ag<CR>

let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>0 <Plug>AirlineSelectTab0
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab
nmap <leader>q :bd<CR>

" PLUGIN CONFIGS
let g:airline#extensions#tabline#enabled = 1

let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_modified_removed = '▎'
let g:gitgutter_sign_removed = '▁'
let g:gitgutter_sign_removed_first_line = '▔'

let g:rustfmt_autosave = 1

let g:gruvbox_contrast_dark='medium'

let g:airline_powerline_fonts = 1

"
" SET OPTIONS
"
" General
set belloff=all
set background=dark
set mouse=a
set ttymouse=xterm2
set hidden
set updatetime=300
set shortmess+=c
set nobackup
set nowritebackup
set noshowmode
" Layout
set signcolumn=yes
set number
set relativenumber
set showtabline=2
set tabstop=4
set expandtab
set splitbelow
set splitright
" Search
set ignorecase
set smartcase
