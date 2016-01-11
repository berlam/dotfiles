set nocompatible
filetype off

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'ervandew/supertab'
Plugin 'bling/vim-airline'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/syntastic'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/AutoClose'
Plugin 'myusuf3/numbers.vim'
Plugin 'tpope/vim-surround'
Plugin 'Blackrush/vim-gocode'
""Plugin 'Shougo/neocomplete.vim'
"All of the Plugins must be added before the following line
call vundle#end()    

filetype plugin indent on
syntax on
let base16colorspace=256
colorscheme base16-3024
set background=dark
set number
set ic
set hls
set lbr
"indents
"set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
"set list
"airline
set laststatus=2
"syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"airline
let g:airline_powerline_fonts = 1
"syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"supertab
let g:SuperTabDefaultCompletionType = "context"
"tagbar
let g:tagbar_usearrows = 1
nnoremap <leader>l :TagbarToggle<CR>
