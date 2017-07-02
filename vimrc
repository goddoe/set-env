set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line

Plugin 'The-NERD-tree'

" Vim에서 자동완성 기능(Ctrl + P)을 키입력하지 않더라도 자동으로 나타나게 - AutoComplPop

Plugin 'AutoComplPop'

Plugin 'majutsushi/tagbar'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'axiaoxin/favorite-vim-colorscheme'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'davidhalter/jedi-vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'Yggdroot/indentLine'

""" sippet!
"Track the engine.
"Plugin 'SirVer/ultisnips'
"" Snippets are separated from the engine. Add this if you want them:
"Plugin 'honza/vim-snippets'
"""

Plugin 'kien/ctrlp.vim'
" Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/syntastic'
Plugin 'nanotech/jellybeans.vim'

call vundle#end()            " required
filetype plugin indent on    " required
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



"Custom add 20160212
" Vim에서 파일 탐색기를 사용할 수 있게 한다. - Nerd Tree
" NERD Tree를 왼쪽에 생성

let NERDTreeWinPos = "left"

" NERD Tree는 F4키.  매칭.
nmap <F7> :NERDTree<CR>
"nmap <F8> :TagbarToggle<CR>
nmap <F8> :TagbarOpen j<CR>

" F5 for run python
if exists("$VIRTUAL_ENV")
	autocmd FileType python map <buffer> <F5> :!$VIRTUAL_ENV'/bin/python' %<CR>
else
	autocmd FileType python map <buffer> <F5> :!python %<CR>
endif



filetype on


" airline!!
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_section_y = '%{strftime("%H:%M")}'
set laststatus=2
set noshowmode
let g:airline_exclude_preview=1

" colorscheme
" colorscheme Tomorrow-Night-Bright
colorscheme jellybeans

" ultsnips
"Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"
" ultisnips end

" indent line
let g:indentLine_enabled = 1 

"ctrlp & NeadTree
let g:NERDTreeChDirMode       = 2
let g:ctrlp_working_path_mode = 'rw'


" autopep8
au FileType python setlocal formatprg=autopep8\ -

" vim-flake8
" let g:flake8_show_in_file=1   " show
" let g:flake8_max_markers=500  " maximum # of markers to show(500 is default)

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" vi 실행시 number line 생성

set nu

" 코딩 작업시 자동 들여쓰기

set smartindent

" 일반모드에서 / 검색시 하이라이팅

set hlsearch

" 일반모드에서 / 검색시 대소문자 구분하지 않음

set ignorecase

" Tab 관련 설정. 일반적으로 가장 많이 쓰이는 tabstop 4, shiftwidth 4

set ts=4
set sw=4
set sts=4
set expandtab "i don't use it!
syntax on
syntax enable

autocmd Filetype html setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 sts=2 expandtab

set backspace=2
set mouse=nicr

" cursor config
highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

autocmd FileType javascript setlocal sw=2 ts=2 sts=2 expandtab
autocmd FileType html       setlocal sw=2 ts=2 sts=2 expandtab
