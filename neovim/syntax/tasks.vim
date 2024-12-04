" Vim syntax file
" Language: TODO tasks
" Maintainer: Michal Nanasi
" Latest Revision: 09 July 2024

if exists("b:current_syntax")
  finish
endif


syn match tasksSection '^##*.*' contains=tasksSectionId
syn match tasksSectionId 's[0-9][0-9]*'
syn match tasksTodo '^\[[^]x]*\]'
syn match tasksTodo '^\[ *\]'  conceal cchar=⬜
syn match taskTodoDoneConceal '\[x\]' conceal cchar=✅ contained
syn match taskTodoCanceledConceal '\[\-\]' conceal cchar=❌ contained
syn region tasksTodoDone start='^\[x\]' end='^\ze\(\[\|#\)' contains=taskTodoDoneConceal,taskError
syn region tasksTodoCanceled start='^\[\-\]' end='^\ze\(\[\|#\)' contains=taskTodoCanceledConceal,taskError
syn region taskFileHeader start='TASK FILE HEADER BEGIN' end='TASK FILE HEADER END' fold
syn match taskError '^\[\([^-x? ][^]]*\|\|..\+\)\]'

" In case you want to fold by markdown sections
" syn region sectionFold start="^\z(#\+\).*" skip="^\z1#\+" end="^\(#\)\@=" fold contains=TOP
" In case you want to fold by only continuous sections of done items 
syn region doneFold start='^\[[-x?]\]' end='^\ze\(\[[^-x?]\|#\)' contains=TOP,doneFold fold

syn match tasksTaskId 't[0-9][0-9]*'
syn match tasksHashTag '#[_a-zA-Z0-9][-_a-zA-Z0-9]*'

let b:current_syntax = "tasks"
hi def link tasksTodoDone Comment
hi def link tasksTodoCanceled Removed " Comment
hi def link tasksTodo Statement
hi def link tasksHashTag Type
hi def link tasksTaskId Statement
hi def link tasksSectionId Todo 
hi def link tasksSection Todo 
hi def link taskFileHeader Comment
hi def link taskError Error
