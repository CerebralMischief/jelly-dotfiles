"colors
colorscheme jellybeans

set nocompatible "turn off vi compatibility, required for vundle"

" vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'

Bundle 'bling/vim-airline'
Bundle 'SirVer/ultisnips'
" SVN integration
Bundle 'vim-scripts/vcscommand.vim'
" Git integration
Bundle 'tpope/vim-fugitive'
" Xdebug integration
Bundle 'joonty/vdebug.git' 

" Tagbar
Bundle 'majutsushi/tagbar'

" Autocmd options
" "--------------------------------
autocmd BufReadPost *.doc silent %!antiword "%" 
autocmd BufWriteCmd *.doc set readonly
autocmd BufReadPost *.odt,*.odp silent %!odt2txt "%"
autocmd BufWriteCmd *.odt set readonly
autocmd BufReadPost *.pdf  silent %!pdftotext -nopgbrk -layout -q -eol unix "%" - | fmt -w78
autocmd BufWriteCmd *.pdf set readonly
autocmd BufReadPost *.rtf silent %!unrtf --text "%"
autocmd BufWriteCmd *.rtf set readonly
autocmd BufRead,BufNewFile ~/.mutt/tmp/* set filetype=mail | set textwidth=72 | set spell |  set wrap | setlocal spell spelllang=nl,en

filetype plugin indent on

" Sprunge
" -------------------------------
command -range=% Share :<line1>,<line2>write !curl -F "sprunge=<-" http://sprunge.us|xclip

" YouCompleteMe
" -------------------------------
let g:ycm_key_list_previous_completion=['<Up>']
let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'objc' : ['->', '.'],
  \   'ocaml' : ['.', '#'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'php' : ['->', '::'],
  \   'cs,java,javascript,d,vim,python,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \ }

" Search
" -------------------------------
set hlsearch

set runtimepath+=/home/jelle/.vim/bundle/ultisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsUsePythonVersion=2

" RST Live Preview
" --------------------------------
autocmd FileType rst silent :! (file="%"; rst2pdf % &>/dev/null && evince "${file/.rst/.pdf}" &>/dev/null) &
command! Reload :! (rst2pdf  % &>/dev/null) &
au BufWritePost *.rst silent Reload


" Vim-airline
" -------------------------------

let g:airline#extensions#tabline#enabled = 1
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_theme = 'jellybeans'

" Tagbar
" ------------------------------
nmap <F8> :TagbarToggle<CR>

syntax on

" Mouse
if has('mouse')
  set mouse=a
endif

" GUI Options GVIM
set guioptions-=mrL

" indenting
set cindent
set smartindent
set autoindent
set complete+=s

" Spell
set spell spelllang=nl,en
set nospell
let g:tex_comment_nospell= 1

" Python stuff
autocmd FileType python let python_highlight_all = 1
autocmd FileType python let python_slow_sync = 1
autocmd FileType python set expandtab shiftwidth=4 softtabstop=4
autocmd FileType python set completeopt=preview

" PKGBUILD stuff
autocmd FileType PKGBUILD set expandtab shiftwidth=2 softtabstop=4
"
" sh stuff
autocmd FileType sh set expandtab shiftwidth=2 softtabstop=4 

" LaTeX
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex setlocal spell 
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex let g:tex_flavor = "latex"

" Vim-debug
" ------------------------------
"let g:vdebug_options["break_on_open"] = 0

" Tags
set tags=./tags,tags;$HOME
