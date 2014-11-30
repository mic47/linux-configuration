"
" Mic's .vimrc 
" inspired by .vimrc by MisoF (http://people.ksp.sk/~misof/programy/vimrc.html)
"

" ======================= GENERAL SECTION ====================================
set timeout
set timeoutlen=200

command! Converttohtml so $vimruntime/syntax/2html.vim

set autoread
map <tab> :tabnext<CR>
imap <tab> <ESC>:tabnext<CR>i
map <C-u> :tabprev<CR>
imap <C-u> <ESC>:tabprev<CR>i
map <C-t> :tabnew<CR>
imap <C-t> <ESC>:tabnew<CR>

imap ˙ <C-o>h
imap ∆ <C-o>j
imap ˚ <C-o>k
imap ¬ <C-o>l
map ˙ h
map ∆ j
map ˚ k
map ¬ l
" ======================= VISUAL AND UI=======================================
set ruler 
set mouse=a
map Q gq " no more Ex mode
syntax on " We want this in any case
set background=dark
" highlight normal guibg=black guifg=white ctermbg=black ctermfg=white 
set wildmode=longest,list,full
set wildmenu
set clipboard=unnamed,unnamedplus
set printoptions=number:y
set cursorline

set incsearch
set ignorecase
set smartcase
set hlsearch

set display+=lastline
set display+=uhex

set statusline=%<%f\ %h%m%r%=char=%b=0x%B\ \ %l,%c,%v\ %p%%
set laststatus=2
set highlight+=s:mystatuslinehighlight
highlight mystatuslinehighlight ctermbg=blue ctermfg=white
au InsertEnter * hi mystatuslinehighlight ctermbg=green ctermfg=white
au InsertLeave * hi mystatuslinehighlight ctermbg=blue ctermfg=white
" Search is more subtle
highlight Search ctermbg=darkgray ctermfg=white

"nnoremap // :noh<cr>
"function! My_tab_completion()
"    if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
"        return "\<c-n>"
"    else
"        return "\<tab>"
"endfunction
"inoremap <tab> <c-r>=My_tab_completion()<cr>
"
"map <tab> <ctrl-ww>
"map <s-tab> <c>w

function! GoogleUnderCursor()
	let s:man = "firefox www.google.sk/search?q="
	let s:wordundercursor = expand("<cword>")
	let s:cmd = "!". s:man . s:wordundercursor." >/dev/null 2>/dev/null &"
	execute s:cmd
endfunction

map <C-G> :call GoogleUnderCursor()<cr><cr>
imap <C-G> <esc>:call GoogleUnderCursor()<cr><cr>i
" TODO: google in visual mode

hi LineNr term=reverse ctermbg=blue guibg=blue
au InsertEnter * hi LineNr term=reverse ctermbg=green guibg=green
au InsertLeave * hi LineNr term=reverse ctermbg=blue    guibg=blue

highlight ColorColumn ctermbg=blue guibg=blue
if exists('+colorcolumn')
  set colorcolumn=80,120
else
  au BufWinEnter * let w:m2=matchadd('ColorColumn', '\%>80v.\+', -1)
endif

" Turn off arrow key
"nnoremap <up> <nop>
"nnoremap <down> <nop>
"nnoremap <left> <nop>
"nnoremap <right> <nop>
"nnoremap <up> <nop>
"inoremap <down> <nop>
"inoremap <left> <nop>
"inoremap <right> <nop>

nnoremap + <C-a>
nnoremap - <C-x>

" faster esc

imap jj <esc>
" ======================= TEXT MANUPULATION SECTION ==========================
set nocompatible 
set backspace=2 
set history=200 

" Languages and encodings
set fencs=utf8,latin2,iso-8859-2,cp1250,utf16,windows-1250
set spelllang=en ",sk
set spell
" ======================= PROGRAMMING AND LATEX SECTION ======================
set shiftwidth=2
set expandtab
set softtabstop=2
set tabstop=2
set smarttab
set autoindent
    "set smartindent


set autowrite
" ======================= UNSORTED ===========================================
" specificke nastavenia pre editovanie konkretnych typov suborov:  {{{

" Specificke nastavenie pre TeX:  {{{
function! TEXSET()
  " make: ak mame Makefile, tak make, inak cslatex + dvips
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ pdfcslatex\ -c-style-error\ %;\ dvips\ `basename\ %\ .tex`;fi;fi
  " set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ cslatex\ -file-line-error-style\ %;\ dvips\ `basename\ %\ .tex`;fi;fi " starsia verzia TeXu
  set errorformat=%f:%l:\ %m

  " aby nam zvyraznilo zle slova aj v zatvorkach, pridame si do syntaxu BADWORD
  syn cluster texMatchGroup contains=@texMathZones,texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,BADWORD

  " najskor ide moj slovnik s najcastejsimi prikazmi
  set complete=k,.,w,b,u,t,i
  let &dictionary =  "~/.vim/dict/tex.dict"
  "set textwidth=80
  set spell
"  map ll :set spelllang=sk
  if executable('aspell')
    exe "set spell spelllang=" . s:guessLang()
  endif

"  set foldmarker=\\begin,\\end
endfunction
" }}}
"
" Speci ficke nastavenie pre LaTeX:  {{{
function! LATEXSET()
  " make: ak mame Makefile, tak make, inak cslatex + dvips
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ latex\ %\ .tex;fi;fi
  " set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ cslatex\ -file-line-error-style\ %;\ dvips\ `basename\ %\ .tex`;fi;fi " starsia verzia TeXu
  set errorformat=%f:%l:\ %m

  " aby nam zvyraznilo zle slova aj v zatvorkach, pridame si do syntaxu BADWORD
  syn cluster texMatchGroup contains=@texMathZones,texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,BADWORD
  syn region  texComment	start="\\begin{comment}" end="\\end{comment}"			contains=@texCommentGroup 

  " najskor ide moj slovnik s najcastejsimi prikazmi
  set complete=k,.,w,b,u,t,i
  let &dictionary =  "~/.vim/dict/tex.dict"
  " set textwidth=80
  set spell
  set spelllang=en
 " set foldmarker=\begin,\end
endfunction

function! CSLATEXSET()
  " make: ak mame Makefile, tak make, inak cslatex + dvips
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ cslatex\ %\ .tex;fi;fi
  " set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ cslatex\ -file-line-error-style\ %;\ dvips\ `basename\ %\ .tex`;fi;fi " starsia verzia TeXu
  set errorformat=%f:%l:\ %m

  " aby nam zvyraznilo zle slova aj v zatvorkach, pridame si do syntaxu BADWORD
  syn cluster texMatchGroup contains=@texMathZones,texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,BADWORD

  " najskor ide moj slovnik s najcastejsimi prikazmi
  set complete=k,.,w,b,u,t,i
  let &dictionary =  "~/.vim/dict/tex.dict"

 " set foldmarker=\begin,\end
endfunction

map <F7> LATEXSET()
" }}}
" Specificke nastavenie pre C/C++:  {{{
function! CSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ gcc\ -g\ -Wall\ -W\ -lm\ -o%.bin\ %;fi;fi
  set errorformat=%f:%l:\ %m
  set cindent
  " Krajsie viacriadkove /* komentare
  set comments-=s1:/*,mb:*,ex:*/
  set comments+=s:/*,mb:**,ex:*/
  set comments+=fb:*
  set foldmarker={{{,}}}
  set fdm=marker
endfunction

function! CPPSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ g++\ -march=core2\ -mtune=core2\ -O2\ -g\ -std=c++11\ -Wall\ -W\ -o%.bin\ %;fi;fi
  set errorformat=%f:%l:%c:\ %m
  set cindent
  " Krajsie viacriadkove /* komentare
  set comments-=s1:/*,mb:*,ex:*/
  set comments+=s:/*,mb:**,ex:*/
  set comments+=fb:*
  set nospell
"  set foldmethod=indent
  set foldmarker=//{{{,//}}}
  set fdm=marker

  map <C-i> ma:%!astyle --indent-classes --pad-oper --pad-paren-out`a

endfunction
"  }}}

" Specificke nastavenie pre Pascal:  {{{
function! PPSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ ppc386\ -o\%bin\ %;fi;fi
  set errorformat=%f:%l:\ %m
  set nospell
endfunction
" }}}

" Specificke nastavenie pre Vim skripty:  {{{
function! VIMSET()
  " v konfiguraku mame dlhe riadky
  set nowrap
  " aj riadky zacinajuce " su komentare
  set comments+=b:\"
  set nospell
endfunction
" }}}

" Specificke nastavenie pre Makefile:  {{{
function! MAKEFILESET()
  " v konfiguraku mame dlhe riadky
  set nowrap
  " potrebujeme taby, nie medzery
  set noet
  set sts=8
  iunmap <Tab>
  set nospell
endfunction
" }}} 

" Specificke nastavenie pre Haskell:  {{{
function! HASKELLSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ ghc\ -o%.bin\ %;fi;fi
  setlocal errorformat=%-GCompiling%.%#,
                    \%E%f:%l:%c:\ %m,
                    \%E%f:%l:%c:%m,
                    \%E%f:%l:%c:,
                    \%+C\ \ %#%m,
                    \%+C\ \ %#%m
  " Krajsie viacriadkove /* komentare
 " set comments-=s1:/*,mb:*,ex:*/
 " set comments+=s:/*,mb:**,ex:*/
  set comments+=fb:*
  set nospell
endfunction

" }}}

" Specificke nastavenie pre Python:  {{{
function! PYTHONSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make;else\ if\ \[\ -f\ \"makefile\"\ \];then\ make;else\ python\ %;fi;fi
  setlocal errorformat=%-GCompiling%.%#,
                    \%E%f:%l:%c:\ %m,
                    \%E%f:%l:%c:%m,
                    \%E%f:%l:%c:,
                    \%+C\ \ %#%m,
                    \%+C\ \ %#%m
  " Krajsie viacriadkove /* komentare
 " set comments-=s1:/*,mb:*,ex:*/
 " set comments+=s:/*,mb:**,ex:*/
  set comments+=fb:*
  set softtabstop=4
  set shiftwidth=4
  set nospell
endfunction

" }}}

function! MEDIAWIKISET()
  set background=light
  syntax on
endfunction

function! PMWIKISET()
  set background=light
  syntax on
endfunction

" Autocommandy pre jednotlive jazyky: {{{
autocmd FileType haskell     call HASKELLSET()
autocmd FileType python      call PYTHONSET()
autocmd FileType vim	     call VIMSET()
autocmd FileType c           call CSET()
autocmd FileType C           call CPPSET()
autocmd FileType cc          call CPPSET()
autocmd FileType cpp         call CPPSET()
autocmd FileType tex         call LATEXSET()
autocmd FileType pascal      call PPSET()
autocmd FileType make        call MAKEFILESET()
autocmd FileType mediawiki   call MEDIAWIKISET()
autocmd FileType pmwiki      call PMWIKISET()
 " }}}
 " }}}
" ======================================================================================================
" OmniCpp {{{

set nocp
filetype plugin on 
map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
let OmniCpp_NamespaceSearch = 2
let OmniCpp_DisplayMode = 0
let OmniCpp_ShowScopeInAbbr = 1
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 0
let OmniCpp_SelectFirstItem = 0
set tags+=~/.stl.tag

" }}}
" ======================================================================================================
" Micove ficurie {{{

" }}}
" =======================================================================

"set fdm=marker
"set commentstring=%s
"set foldmarker={,}

" a na zaver povieme vimku, nech posklada foldy do seba
"" vim: fdm=marker:commentstring=\ \"\ %s 

" autocmd FileType python compiler pylint


inoremap <F2> <C-R>=ListNotes()<CR>
inoremap <F3> <C-R>=ListNotes()<CR>

func! ListNotes()
  call complete(col('.'), ['\correction{}{}', '\todo{}', '\firstUseOf{}', '\abbreviation{}{}', '\colornote{yellowcolor}{}'])
  return ''
endfunc

augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'mhinz/vim-signify'
Plugin 'mbbill/undotree'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'Valloric/YouCompleteMe'
Bundle 'jordwalke/VimSplitBalancer'
"Plugin 'showmarks'
let g:ycm_filetype_specific_completion_to_disable = {}
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" from vimbits.com
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Improve up/down on wrapped lines
nnoremap j gj
nnoremap k gk

" Disable paste when leaving insert mode
au InsertLeave * set nopaste

" Relative in normal mode
"set rnu --- nefunguje spat nu TODO
set number
set relativenumber
au InsertEnter * set norelativenumber
au InsertLeave * set relativenumber

" Persistend undo: help undo-persistent
if exists("+undofile")
" undofile - This allows you to use undos after exiting and restarting
" This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence
" This is only present in 7.3+
    if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=~/.vim/undo//
    set undofile
endif

" Toogle paste
set pastetoggle=<F2> "enable paste toggle and map it to F8


"80 character line color: TODO: softer color (darkgray)


    " ****************** SCROLLING *********************
     
    set scrolloff=8 " Number of lines from vertical edge to start scrolling
    set sidescrolloff=15 " Number of cols from horizontal edge to start scrolling
    set sidescroll=1 " Number of cols to scroll at a time



