set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'     " git command wrapper
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'Yggdroot/indentLine'
Plugin 'majutsushi/tagbar'
Bundle 'Valloric/YouCompleteMe'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'sheerun/vim-polyglot'  " highlight plugin
Plugin 'dense-analysis/ale'     " linter & fixer
Plugin 'Xuyuanp/nerdtree-git-plugin'
"Plugin 'ryanoasis/vim-devicons'
"Plugin 'davidhalter/jedi-vim'
"Plugin 'vim-syntastic/syntastic'

" indentLine settings {{{
let g:indentLine_char = "┆"
let g:indentLine_enabled = 1
let g:autopep8_disable_show_diff=1
" }}}

" zenburn and solarized settings {{{
if has('gui_running')
  set background=dark
  colorscheme solarized
else
  colorscheme zenburn
endif

" F5 to switch between Solarized dark and light mode
call togglebg#map("<F5>")
" }}}

" nerdtree settings {{{
" hide pyc files in nerdtree
let NERDTreeIgnore=['\.pyc$', '\.git$', '\.swp$', '__pycache__', '\~$'] "ignore files in NERDTree

map <F2> :NERDTreeToggle<CR>
let NERDTreeChDirMode=1
let NERDTreeShowBookmarks=1

let NERDTreeWinSize=30
let NERDTreeShowHidden=1
autocmd vimenter * if !argc() || argc() == 1 | NERDTree | wincmd p | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <leader>tn :tabnew 
" }}}

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" Split navigations settings {{{
set splitright
set splitbelow
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" }}}

" Folding settings {{{
" folding method turn-on
set foldmethod=indent
set foldlevel=99

" YouCompleteMe settings {{{
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
" }}}

" fold with space bar
nnoremap <space> za

let g:SimpylFold_docstring_preview=1
" }}}

" Intentation settings {{{
"   TODO: use Vimjas/vim-python-pep8-indent plugin later
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2
" }}}

" Flagging Unnecessary Whitespace
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" python virtualenv support settings {{{
"py3 << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
"  project_base_dir = os.environ['VIRTUAL_ENV']
"  activate_this = os.path.join(project_base_dir, 'bin/activate')
"  execfile(activate_this, dict(__file__=activate_this))
"EOF
" }}}



set encoding=utf-8

"let python_highlight_all=1
"syntax o\

set nu
:set backupcopy=yes

" Auto add head info
" .py file into add header
function HeaderPython()
    call setline(1, "#!/usr/bin/env python")
    call append(1, "# -*- coding: utf-8 -*-")
    normal G
    normal o
endf
autocmd bufnewfile *.py call HeaderPython()

" ale settings {{{
let g:ale_linters = {
\   'python': ['flake8', 'mypy'],
\   'ruby': ['standardrb', 'rubocop'],
\   'javascript': ['eslint'],
\}

let g:ale_fixers = {
\   'python': ['isort', 'black'],
\   'javascript': ['eslint'],
\}

let pipenv_venv_path = system('pipenv --venv')
let g:ale_python_auto_pipenv = 1
let g:ale_python_auto_poetry = 1
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_linters_explicit = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] [%severity%] %code: %%s'

function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✨ all good ✨' : printf(
    \ '😞 %dW %dE',
    \ all_non_errors,
    \ all_errors
    \)
endfunction

set statusline=
set statusline+=%m
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %{LinterStatus()}

" }}}

let &t_TI = ""
let &t_TE = ""

map <F9> <Esc>:w<CR>:!clear;python %<CR>

" returns true iff is NERDTree open/active
function! s:isNTOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" calls NERDTreeFind iff NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
function! s:syncTree()
  if &modifiable && s:isNTOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

autocmd BufEnter * call s:syncTree()

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif
"autocmd TabEnter * NERDTree | NERDTreeFind | wincmd p 

" prevent from opening any file in tree window when it is focused
"let g:fzf_layout = { 'window': 'let g:launching_fzf = 1 | keepalt topleft 100split enew' }

"autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
"autocmd BufWinEnter * call PreventBuffersInNERDTree()

"function! PreventBuffersInNERDTree()
"  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
"    \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
"    \ && &buftype == '' && !exists('g:launching_fzf')
"    let bufnum = bufnr('%')
"    close
"    exe 'b ' . bufnum
"  endif
"  if exists('g:launching_fzf') | unlet g:launching_fzf | endif
"endfunction


au BufEnter * if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree' && winnr('$') > 1 | b# | exe "normal! \<c-w>\<c-w>" | :blast | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"set hidden
set hlsearch

" can access system clipboard
set clipboard=unnamed

" reload vimrc
nnoremap <Leader>vr :source $MYVIMRC<CR>

" git status support in NERDTree
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  :'✹',
    \ 'Staged'    :'✚',
    \ 'Untracked' :'✭',
    \ 'Renamed'   :'➜',
    \ 'Unmerged'  :'═',
    \ 'Deleted'   :'✖',
    \ 'Dirty'     :'✗',
    \ 'Ignored'   :'☒',
    \ 'Clean'     :'✔︎',
    \ 'Unknown'   :'?',
\}


