" Vim syntax file
" Language:	HP-41CL mem_ref file
" Version:	0.5
" Maintainer:	Geir Isene
" Last Change:	2017-12-25
" URL:		http://isene.com/

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax match  clADDR "^[0-9A-F]\{3}"
syntax match  clDIV  "^----*"
syntax match  clDIV  "^====*"
syntax match  clROM  " .*\.ROM"
syntax match  clID   "  [0-9A-Z:-]\{4} "
syntax match  clXROM "  \d\{1,2}  "
syntax match  clXRNA "  N/A  "
syntax match  clCRC  "0x........"
syntax match  clDATE "\d\d/\d\d/\d\d"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_crontab_syn_inits")
  if version < 508
    let did_crontab_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink clADDR Number
  HiLink clDIV  Function
  HiLink clROM  Label
  HiLink clID   Type
  HiLink clXROM Comment
  HiLink clXRNA Comment
  HiLink clCRC  Define
  HiLink clDATE Number

  delcommand HiLink
endif

let b:current_syntax = "hp41clmemref"

" vim: ts=8
