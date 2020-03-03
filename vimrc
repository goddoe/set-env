" Author : Sung-ju Kim
" Github : https://github.com/goddoe

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Vim script library
" l9 is a Vim-script library, which provides some utility functions and commands for programming in Vim.
" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'

" write HTML code faster
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" navigator
Plugin 'tpope/vim-fugitive' " Git Wrapper
Plugin 'git://git.wincent.com/command-t.git' " Opening files and buffers, Jumping to tags and help, Running commands, or previous searches and commands
Plugin 'The-NERD-tree'
Plugin 'majutsushi/tagbar'
Plugin 'ctrlpvim/ctrlp.vim'

" autocomplete
Plugin 'Valloric/YouCompleteMe'

" lint
Plugin 'w0rp/ale'

" snippets
Plugin 'SirVer/ultisnips' 
Plugin 'honza/vim-snippets'

" theme
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'axiaoxin/favorite-vim-colorscheme'

" syntax
Plugin 'posva/vim-vue'

" env
Plugin 'https://github.com/jpalardy/vim-slime.git'

" for python
Plugin 'mgedmin/python-imports.vim'

" etc
Plugin 'terryma/vim-multiple-cursors'
Plugin 'airblade/vim-gitgutter'
Plugin 'Yggdroot/indentLine'

call vundle#end()            " required
filetype plugin indent on    " requiredk
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" vim-slime
let g:slime_target="tmux"
let g:slime_paste_file = tempname()
let g:slime_python_ipython=1

" YouCompleteMe
let g:ycm_python_binary_path='python3'

" ale
let g:ale_python_flake8_options = '--ignore=F405'

" NERD Tree
let NERDTreeWinPos="left"
nmap <F7> :NERDTree<CR>
"nmap <F8> :TagbarToggle<CR>
nmap <F8> :TagbarOpen j<CR>
" airline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#left_sep=' '
let g:airline#extensions#tabline#left_alt_sep='|'
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline_section_y = '%{strftime("%H:%M")}'
set laststatus=2
set noshowmode
let g:airline_exclude_preview=1

" colorscheme
" colorscheme Tomorrow-Night-Bright

" ultsnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<F4>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"
" let g:UltiSnipsSnippetsDir='~/.vim/snips'
" let g:UltiSnipsSnippetDirectories=['snips', 'UltiSnips']
let g:snips_author="Sung-ju Kim"
let g:snips_email="goddoe2@gmail.com"
let g:snips_github="https://github.com/goddoe"

" indent line
let g:indentLine_enabled=1 

"ctrlp & NeadTree
let g:NERDTreeChDirMode=2
let g:ctrlp_working_path_mode='rw'

" F5 for run python
if exists("$VIRTUAL_ENV")
	autocmd FileType python map <buffer> <F5> :!$VIRTUAL_ENV'/bin/python' %<CR>
else
	autocmd FileType python map <buffer> <F5> :!python %<CR>
endif

" autopep8
au FileType python setlocal formatprg=autopep8\ -

if !exists("g:syntax_on")
    syntax enable
endif

set nu
set hlsearch " highlight on search
set ignorecase " ignorecase on search
set mouse=a

set smartindent
set ts=4
set sw=4
set sts=4
set expandtab 
set backspace=2
vnoremap // y/<C-R>"<CR>

autocmd Filetype html setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype vue setlocal ts=2 sw=2 sts=2 expandtab 

nmap <F6> :IndentLinesToggle<CR>:set invnumber<CR>
map <F9> :ImportName<CR>
map <C-F9> :ImportNameHere<CR>
