if exists('g:loaded_watcher_provider')
  finish
endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to vim defaults

command! -nargs=1 Watch call luaeval("require('autoread').watch(_A)", expand('<args>')) 
command! -nargs=1 Stop call luaeval("require('autoread').stop_watch(_A)", expand('<args>'))

" function to prompt the user for a reload
function! PromptReload()
  let choice = confirm("File changed. Would you like to reload?", "&Yes\n&No", 1)
  if choice == 1
    edit!
  endif
endfunction

function! PrintWatchers()
  call luaeval("require('autoread').print_all()")
endfunction

augroup autoread
  autocmd!
  au BufRead,BufWritePost * Watch <afile>
  au BufDelete,BufUnload,BufWritePre * Stop <afile>
  au FocusLost * call luaeval("require('autoread').pause_notif_all()")
  au FocusGained * call luaeval("require('autoread').resume_notif_all()")
augroup END

let &cpo = s:save_cpo " restore user coptions
unlet s:save_cpo

let g:loaded_watcher_provider = 1
