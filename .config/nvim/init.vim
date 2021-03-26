call plug#begin('~/.vim/plugged')

" Collection of common configurations for the Nvim LSP client
Plug 'neovim/nvim-lspconfig'
" Plug 'tjdevries/lsp_extensions.nvim'
Plug '~/Workspace/lsp_extensions.nvim'
Plug 'hrsh7th/nvim-compe' " Autocompletion framework for built-in LSP
Plug 'nvim-lua/lsp-status.nvim' " LSP Status
Plug 'anott03/nvim-lspinstall' " LSP Installer

"Git
Plug 'airblade/vim-gitgutter'

" Session

" Fuzzy
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'nvim-lua/popup.nvim'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim'

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'akinsho/nvim-bufferline.lua' " Requires a Nerd Font
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kosayoda/nvim-lightbulb'
Plug 'glepnir/lspsaga.nvim'
Plug 'morhetz/gruvbox'
Plug 'kyazdani42/nvim-tree.lua'

" Syntactic language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-commentary'
Plug 'hrsh7th/vim-vsnip'

" Semantics
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug '~/Workspace/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
" Plug 'romgrk/nvim-treesitter-context'
Plug 'Raimondi/delimitMate'

call plug#end()

syntax enable
filetype plugin indent on

let g:vimsyn_embed = 'l'
set termguicolors
let g:gruvbox_contrast_dark='medium'
colorscheme gruvbox

" Source the lua init
call v:lua.require('init')

" LSP Status 
function! LspStatus() abort
    if luaeval('#vim.lsp.buf_get_clients() > 0')
       return luaeval("require('lsp-status').status()")
    endif
    return ''
endfunction

" Rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

let g:lightline = {'enable': {'tabline': 0}}
let g:lightline.colorscheme = 'gruvbox'
let g:lightline.active = {'left': [[ 'mode', 'paste' ], [ 'lsp' ]] }
let g:lightline.component_function = {'lsp': 'LspStatus'}

let g:nvim_tree_show_icons = {'git': 1, 'folders': 1, 'files': 1}
let g:nvim_tree_bindings = {
    \ 'edit':            ['<CR>', 'o'],
    \ 'edit_vsplit':     '<C-v>',
    \ 'edit_split':      '<C-x>',
    \ 'edit_tab':        '<C-t>',
    \ 'close_node':      ['<S-CR>', '<BS>'],
    \ 'toggle_ignored':  'I',
    \ 'toggle_dotfiles': 'H',
    \ 'refresh':         'R',
    \ 'preview':         '<Tab>',
    \ 'cd':              '<C-]>',
    \ 'create':          'a',
    \ 'remove':          'd',
    \ 'rename':          'r',
    \ 'cut':             'x',
    \ 'copy':            'c',
    \ 'paste':           'p',
    \ 'prev_git_item':   '[c',
    \ 'next_git_item':   ']c',
    \ 'dir_up':          '-',
    \ 'close':           'q',
    \ }

" Gitgutter 
let g:gitgutter_map_keys = 0
let g:gitgutter_max_signs = 10000
let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_modified_removed = '▎'
let g:gitgutter_sign_removed = '▁'
let g:gitgutter_sign_removed_first_line = '▔'

" let g:blameLineVirtualTextFormat = '[%s]'
" Open hotkeys
map <C-p> :GFiles<CR>
map <C-P> :Files<CR>
nmap <leader>; :Buffers<CR>
" nnoremap <C-p> <cmd>Telescope git_files<cr>
" nnoremap <C-P> <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>

"Search
map <leader>f :Ag<CR>

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })
inoremap <silent><expr> <C-e>     compe#close('<C-e>')

" Code Actions
nnoremap <silent><leader>ca :Lspsaga code_action<CR>
vnoremap <silent><leader>ca :<C-U>Lspsaga range_code_action<CR>
" Hover doc, enabled on CursorHold
" nnoremap <silent>K :Lspsaga hover_doc<CR>
" Signature help
nnoremap <silent> gs :Lspsaga signature_help<CR>
" Rename 
nnoremap <silent>gr :Lspsaga rename<CR>
" Definition preview
nnoremap <silent> gd :Lspsaga preview_definition<CR>

" Goto previous/next diagnostic warning/error
nnoremap <silent> [e :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]e :Lspsaga diagnostic_jump_prev<CR>

nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>

noremap <leader>gd <Cmd>lua vim.lsp.buf.definition()<CR>
noremap <leader>gD <Cmd>lua vim.lsp.buf.declaration()<CR>

nnoremap <silent> <leader>ff :Lspsaga lsp_finder<CR>

" Show diagnostic popup on cursor hold
" using regular LSP diagnostics for now, which are inline virtual text opposed
" to a popup from lspsaga
" autocmd CursorHold * lua vim.defer_fn(function() require'lspsaga.diagnostic'.show_line_diagnostics() end, 2000)

" Show definition on cursor hold
" autocmd CursorHold * lua vim.defer_fn(function() require'lspsaga.provider'.preview_definition() end, 2000)

" Show doc on cursor hold
" autocmd CursorHold * lua vim.defer_fn(function() require('lspsaga.hover').render_hover_doc() end, 5000)

" Lightbulb
autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()

" Enable type inlay hints
autocmd BufEnter,BufWinEnter,InsertLeave,TabEnter,BufWritePost *.rs :lua require'lsp_extensions'.rust_analyzer.inlay_hints{ prefix = '', highlight = "NonText", enabled = {"ChainingHint", "TypeHint", "ParameterHint"} }

" Highlight on yank
autocmd TextYankPost * silent! lua vim.highlight.on_yank()

" Control keymaps
" Esc
nnoremap <C-c> <Esc>
inoremap <C-c> <Esc>
vnoremap <C-c> <Esc>
snoremap <C-c> <Esc>
xnoremap <C-c> <Esc>
cnoremap <C-c> <Esc>
onoremap <C-c> <Esc>
lnoremap <C-c> <Esc>
tnoremap <C-c> <Esc>

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/
" Clear highlights after search
nnoremap <silent> <leader>nh :noh<CR>

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menu,menuone,noselect
" Avoid showing extra messages when using completion
set shortmess+=c
" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set hidden
set updatetime=300
set signcolumn=yes
set scrolloff=10
set nojoinspaces
set splitright
set splitbelow
set formatoptions=tcrqnj
set incsearch
set ignorecase
set smartcase
set tabstop=4
set shiftwidth=4
set expandtab
set number
set showtabline=2
set relativenumber
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic
set showcmd
set noshowmode
set mouse=a
set guicursor=a:block-blinkon0,i:blinkwait50-blinkon200-blinkoff150

" Buffer movement
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Hardmode
map <up> <nop>
map <down> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
map <del> <nop>
imap <del> <nop>
" Left and right can switch buffers
nnoremap <silent> <left> :bp<CR>
nnoremap <silent> <right> :bn<CR>
noremap <silent> <leader>c :bd<CR>

" Terminal
nnoremap <silent> <C-T> :split\|:term<CR>z20<CR>i
tnoremap <Esc> <C-\><C-n>
tnoremap <C-c> <C-\><C-n>

" Tree 
nnoremap <silent> <C-n> :NvimTreeToggle<CR>
nnoremap <silent> <leader>tr :NvimTreeRefresh<CR>
