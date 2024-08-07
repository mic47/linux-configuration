echo "USE NEOVIM!"
"
" Mic's .vimrc 
" inspired by .vimrc by MisoF (http://people.ksp.sk/~misof/programy/vimrc.html)
"

" ======================= GENERAL SECTION ====================================

" TODO extract into plugins:
" 1. [x] Redirect to github platypus-vim-code-browse
" 2. [x] Search platypus-vim-grep
" 3. tmux / terminal platypus-vim-tmux-integration
" 4. itemrm2 integration platypus-vim-iterm2
" 5. latex / other old stff -- platypus-vim-historic
" 6. my general UI -- platypus-vim-ui
" TODO, format:
" 1. General config
" 2. Plugins
" 3. Plugin customization
" 4. Filetype mappings

set timeout
set timeoutlen=200

command! ConvertToHTML so $VIMRUNTIME/syntax/2html.vim

set autoread
"map <tab> :bnext<CR>
"map <S-tab> :bprev<CR>

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

if !has('nvim')
  set ttymouse=sgr
endif

set laststatus=2
" Search is more subtle
highlight Search ctermbg=darkgray ctermfg=white

set synmaxcol=2048

nnoremap + <C-a>
nnoremap - <C-x>

" faster esc

imap jj <esc>

" dfasdf
let s:iterm   = exists('$ITERM_PROFILE') || exists('$ITERM_SESSION_ID') || filereadable(expand("~/.vim/.assume-iterm"))
let s:screen  = &term =~ 'screen'
let s:tmux    = exists('$TMUX')
let s:xterm   = &term =~ 'xterm'

function! s:EscapeEscapes(string)
  " double each <Esc>
  return substitute(a:string, "\<Esc>", "\<Esc>\<Esc>", "g")
endfunction

function! s:TmuxWrap(string)
  if strlen(a:string) == 0
    return ""
  end

  let tmux_begin  = "\<Esc>Ptmux;"
  let tmux_end    = "\<Esc>\\"

  return tmux_begin . s:EscapeEscapes(a:string) . tmux_end
endfunction

" change shape of cursor in insert mode in iTerm 2
if s:iterm
  let start_insert  = "\<Esc>]50;CursorShape=1\x7"
  let end_insert    = "\<Esc>]50;CursorShape=0\x7"

  if s:tmux
    let start_insert  = s:TmuxWrap(start_insert)
    let end_insert    = s:TmuxWrap(end_insert)
  endif

  let &t_SI = start_insert
  let &t_EI = end_insert
endif

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

  " map <C-i> ma:%!astyle --indent-classes --pad-oper --pad-paren-out`a

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
  " let b:ale_linters = ['mypy', 'pylint']
  setlocal foldmethod=indent
endfunction

" }}}

let g:ale_fixers = {
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \ 'typescriptreact': ['eslint'],
  \ 'python': ['mypy', 'pylint'],
  \ 'cs': ['OmniSharp']
  \ }
let g:ale_linters = {
  \ 'python': ['mypy', 'pylint'],
  \ 'cs': ['OmniSharp']
  \ }

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

" }}}
" ======================================================================================================
" Micove ficurie {{{

" }}}
" =======================================================================

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

"let g:vundle_default_git_proto = 'git'
""" BEGIN OF VUNDLE
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" My own plugins
Plugin 'mic47/platypus-vim-code-browse'
" External plugins

Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'voldikss/vim-floaterm'
Plugin 'mhinz/vim-signify'
Plugin 'mbbill/undotree'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
Plugin 'eagletmt/ghcmod-vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'vito-c/jq.vim'
" Plugin 'YouCompleteMe', {'pinned': 1}
Plugin 'ryanoasis/vim-webdevicons'
Plugin 'bling/vim-airline'
Plugin 'dodie/vim-disapprove-deep-indentation'
Plugin 'stevearc/vim-arduino'
Plugin 'derekwyatt/vim-scala'  " maybe conflicts with ensime-vim
Plugin 'tpope/vim-fugitive'
" Plugin 'shumphrey/fugitive-gitlab.vim'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-abolish'
Plugin 'airblade/vim-gitgutter'
Plugin 'majutsushi/tagbar'
Plugin 'luben/sctags'
Plugin 'bam9523/vim-decompile'
Bundle 'https://github.com/prashanthellina/follow-markdown-links'
Plugin 'w0rp/ale'
Plugin 'ambv/black'
Plugin 'hashivim/vim-terraform'
Plugin 'vim-python/python-syntax'
Plugin 'leafgarland/typescript-vim'
Plugin 'nathanaelkane/vim-indent-guides'
" C#
Bundle 'OmniSharp/omnisharp-vim'
" Typescript
"Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'prettier/vim-prettier', { 'do': 'yarn install', 'for': ['typescript', 'javascript'] }
Plugin 'AndrewRadev/linediff.vim'
" Diff
Plugin 'chrisbra/vim-diff-enhanced'
"Plugin 'showmarks'
" let g:ycm_filetype_specific_completion_to_disable = {}
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
""" BEGIN OF VUNDLE

let g:code_browse_browser_cmd="firefox"
"C-G to open code selection in browser"
map <silent> <C-G> <Plug>(code_browse_browser)
map <silent> <Leader>g <Plug>(code_browse_browser)
map <silent> <C-F> <Plug>(code_browse_grep)

map <C-P> :GFiles<CR>
imap <C-P> <ESC>:GFiles<CR>i

let g:terraform_align=1


let g:LookOfDisapprovalTabTreshold=5
let g:LookOfDisapprovalSpaceTreshold=(&tabstop*5)
autocmd FileType tf let g:LookOfDisapprovalTabThreshold=0 | let g:LookOfDisapprovalSpaceThreshold=0

let g:signify_sign_overwrite = 0

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

" from https://gist.github.com/mrmrs/5995435
if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = win_getid()
    execute a:wincmd
    if previous_winnr == win_getid()
      " The sleep and & gives time to get back to vim so tmux's focus tracking
      " can kick in and send us our ^[[O
      execute "silent !sh -c 'sleep 0.01; tmux " . a:tmuxdir . "' &"
      redraw!
    endif
  endfunction
  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te
  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('wincmd h', 'select-pane -L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('wincmd j', 'select-pane -D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('wincmd k', 'select-pane -U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('wincmd l', 'select-pane -R')<cr>
  " Due to the long standing design bug in vim, C-i is same thing as Tab, so
  " it is not a good idea to remap it.
  " nnoremap <silent> <C-i> :call TmuxOrSplitSwitch("execute ':tabnext ' . (tabpagenr() +1)", 'select-window -n')<cr>
  nnoremap <silent> <C-u> :call TmuxOrSplitSwitch("execute ':tabnext ' . (tabpagenr() -1)", 'select-window -p')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
  "map <C-i> :tabnext<cr>
  map <C-u> :tabprev<cr>
endif 

" Improve up/down on wrapped lines
"nnoremap j gj
"nnoremap k gk

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


let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_section_b = ''
let g:airline_section_x = ''
let g:airline_section_y = ''
set t_Co=256


function! SCTags()
    if executable("sctags")
        let g:tagbar_ctags_bin = "sctags"
        let g:tagbar_type_scala = {
            \ 'ctagstype' : 'scala',
            \ 'sro'       : '.',
            \ 'kinds'     : [
                \ 'p:packages',
                \ 'V:values',
                \ 'v:variables',
                \ 'T:types',
                \ 't:traits',
                \ 'o:objects',
                \ 'O:case objects',
                \ 'c:classes',
                \ 'C:case classes',
                \ 'm:methods:1'
            \ ],
            \ 'kind2scope'  : {
                \ 'p' : 'package',
                \ 'T' : 'type',
                \ 't' : 'trait',
                \ 'o' : 'object',
                \ 'O' : 'case_object',
                \ 'c' : 'class',
                \ 'C' : 'case_class',
                \ 'm' : 'method'
            \ },
            \ 'scope2kind'  : {
                \ 'package' : 'p',
                \ 'type' : 'T',
                \ 'trait' : 't',
                \ 'object' : 'o',
                \ 'case_object' : 'O',
                \ 'class' : 'c',
                \ 'case_class' : 'C',
                \ 'method' : 'm'
            \ }
        \ }
    endif
endfunction

if has("autocmd")
    autocmd FileType scala call SCTags()
endif

set tags=.generated.sctags;.generated.ctags;/

noremap <Up> <nop>
noremap <Down> <nop>
noremap <Left> <nop>
noremap <Right> <nop>
set grepprg=crep
set formatprg=par\ w110
set nowrap
set formatoptions-=t

let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'haskell', 'scala', 'javascript', 'sql', 'json']
let g:markdown_syntax_conceal = 0
let g:vim_json_conceal=0

let g:python_highlight_all = 1

let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
  \  'g:ycm_python_interpreter_path',
  \  'g:ycm_python_sys_path'
  \]
let g:ycm_global_ycm_extra_conf = '~/.global_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_auto_hover = 'CursorHold'
let g:ycm_always_populate_location_list = 1

inoremap <expr> <C-e> fzf#vim#complete(fzf#wrap({
  \ 'source':  'python3 /home/mic/Code/Personal/platypus-desk-todo/parse-emoji.py',
  \ 'options': '--header "Emoji Selection" --no-hscroll --delimiter : --nth 2',
  \ 'reducer': { lines -> join(split(lines[0], ':')[:1], '') }}))

let g:OmniSharp_selector_ui = ''
autocmd CursorHold *.cs OmniSharpTypeLookup

let g:coc_global_extensions = ['coc-tsserver']
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)
let g:indent_guides_auto_colors = 0  
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=16

nmap <silent> gh <Plug>(YCMHover)
highlight Pmenu ctermbg=black guibg=black ctermfg=white
"function! RUSTSET()
  "nmap <silent> gd <Plug>(coc-definition)
  "nmap <silent> gc <Plug>(coc-type-definition)
  "nmap <silent> gi <Plug>(coc-implementation)
  "nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gd :YcmCompleter GoToDefinition<CR>
  nmap <silent> gc :YcmCompleter GoToDeclaration<CR>
  nmap <silent> gu :YcmCompleter GoToCallers<CR>
  nmap <silent> gr :YcmCompleter GoToReferences<CR>
  nmap <silent> gf <Plug>(YCMFindSymbolInWorkspace)
  nmap <silent> gt :YcmCompleter GetType<CR>
  nmap <silent> go :YcmCompleter GetDoc<CR>
  nmap <silent> gx :YcmCompleter FixIt<CR>
  nmap <silent> gy :YcmCompleter Format<CR>
  let b:ycm_hover = { 'command': 'GetDoc', 'syntax': &syntax }
"endfunction
"autocmd FileType rust call RUSTSET()

function! TSSET()
  nmap <silent> gy :Prettier<CR>
endfunction
autocmd FileType typescript call TSSET()

highlight DiffAdd    cterm=bold ctermbg=DarkBlue guibg=DarkBlue
highlight DiffDelete term=bold ctermfg=12 ctermbg=DarkCyan gui=bold guifg=Blue guibg=DarkCyan
highlight DiffChange cterm=bold ctermbg=black guibg=DarkGray
highlight DiffText   cterm=bold ctermbg=DarkGray guibg=DarkGray

set diffopt+=internal,algorithm:patience
"nnoremap <C-M> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
"      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
"      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

hi SpellBad term=reverse ctermbg=darkred gui=undercurl guisp=Red

set expandtab
" Quickfix
if version > 801
  set switchbuf+=uselast
endif
set backupcopy=yes
function AddTask()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:2^yw'qf]a tp
    call setpos('.', cursor_pos)
    normal! llllll
endfunction
command! AddTask call AddTask()
function AddSection()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:3^yw'q^k$ea sp
    call setpos('.', cursor_pos)
    normal! llllll
endfunction
command! AddSection call AddSection()
function InitTaskFile()
    let uuid = trim(system("uuidgen"))
    call append(0, ["TASK FILE HEADER BEGIN", "0000", "0000", uuid, "TASK FILE HEADER END"])
endfunction
command! InitTaskFile call InitTaskFile()

function StoreTaskFile()
    execute 'silent !python $HOME/Code/Personal/platypus-tasks/parse.py ' . expand('%')
    redraw!
endfunction
command! StoreTaskFile call StoreTaskFile()
autocmd BufWritePost *.tasks call StoreTaskFile()
"command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
