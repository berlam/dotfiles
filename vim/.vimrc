" Should be already the case but better safe than sorry
set nocompatible

" Use system clipboard
set clipboard=unnamedplus

" Required for operations modifying multiple buffers like rename.
set hidden

" Disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
if &term =~ '256color'
	set t_ut=
endif

" Plugins
call plug#begin('~/.vim/bundle')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'chriskempson/base16-vim'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-dadbod'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'airblade/vim-gitgutter'
Plug 'glacambre/firenvim'
call plug#end()

" Settings
syntax on
filetype plugin indent on

" Theme
let base16colorspace=256
colorscheme base16-3024

" Relative line number in command mode
" Absolute line number in insert mode
set relativenumber
set number
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber 

" netrw tree
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Search case-insensitive when lowercase
set smartcase

" Highlight searched words
set hls

set laststatus=2

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" Firenvim
if exists('g:started_by_firenvim')
	let g:firenvim_config = {'localSettings':{'.*':{'takeover':'never'}}}
	set laststatus=0
	set spell spelllang=en_us,de_de
	" Airline
	let g:airline_disable_statusline = 1
	let g:airline#extensions#tabline#enabled = 0
	" Start in insert mode
	autocmd VimEnter,BufRead,BufNewFile * start
	" Write to page
	let g:dont_write = v:false
	function! My_Write(timer) abort
		let g:dont_write = v:false
		write
	endfunction

	function! Delay_My_Write() abort
		if g:dont_write
			return
		end
		let g:dont_write = v:true
		call timer_start(10000, 'My_Write')
	endfunction

	autocmd TextChanged * ++nested call Delay_My_Write()
	autocmd TextChangedI * ++nested call Delay_My_Write()
endif

" Keys
" Space is the leader
let mapleader = "\<Space>"
" Shift+Enter to wq
nnoremap <S-CR> :wq!<CR>
inoremap <S-CR> <ESC>:wq!<CR>
" Disable arrow keys. Use HJKL.
noremap <Up> <nop>
inoremap <Up> <nop>
noremap <Down> <nop>
inoremap <Down> <nop>
noremap <Left> <nop>
inoremap <Left> <nop>
noremap <Right> <nop>
inoremap <Right> <nop>
" Open new file
nnoremap <Leader>o :CtrlP<CR>
" Save file
nnoremap <Leader>w :w<CR>
" remove markup from highlighted words
nnoremap <esc><esc> :silent! nohls<cr>
