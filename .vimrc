"colors
colorscheme candycode


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
autocmd BufRead,BufNewFile ~/.mutt/tmp/* set filetype=mail | set textwidth=72 | set spell |  set wrap | setlocal spell spelllang=nl

filetype plugin indent on

" Sprunge
" "-------------------------------
command -range=% Share :<line1>,<line2>write !curl -F "sprunge=<-" http://sprunge.us|xclip


" LaTeX Live Preview
" "--------------------------------
autocmd FileType tex silent :! (file="%"; pdflatex % &>/dev/null && zathura "${file/.tex/.pdf}" &>/dev/null) &
command! Reload :! (pdflatex % &>/dev/null) &
au BufWritePost *.tex silent Reload 

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


" Python stuff
autocmd FileType python let python_highlight_all = 1
autocmd FileType python let python_slow_sync = 1
autocmd FileType python set expandtab shiftwidth=4 softtabstop=4
autocmd FileType python set completeopt=preview
"
" " PKGBUILD stuff
autocmd FileType PKGBUILD set expandtab shiftwidth=2 softtabstop=4
"
" " sh stuff
autocmd FileType sh set expandtab shiftwidth=2 softtabstop=4 


" LaTeX
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex set spell
autocmd Filetype tex,latex set setlocal spell spelllang=nl
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex let g:tex_flavor = "latex"

" Neocomplcache
let g:neocomplcache_enable_at_startup = 1 
let g:neocomplcache_enable_auto_select = 1 
let g:neocomplcache_enable_smart_case =1



autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
